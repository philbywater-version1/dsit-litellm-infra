#!/bin/bash

# Usage: ./filter_terraformer_plan.sh [tag_key] [tag_value] [resources]
# Example: ./filter_terraformer_plan.sh Title AIEL
# Example with custom resources: ./filter_terraformer_plan.sh Title AIEL sg,vpc,subnet

TAG_KEY="${1:-Title}"
TAG_VALUE="${2:-AIEL}"
RESOURCES="${3:-sg,vpc,subnet,alb,eni,route_table,igw,nat,nacl,vpc_endpoint,s3,wafv2_regional,ecr,ecs,rds,secretsmanager}"
REGION="eu-west-2"

REGIONAL_PLAN_FILE="./generated/aws/terraformer/plan.json"
IAM_PLAN_FILE="/tmp/plan_iam_original.json"
FILTERED_PLAN="/tmp/plan_filtered.json"
IAM_FILTERED_PLAN="/tmp/plan_filtered_iam.json"

# Resource types filtered by tag
TAG_FILTERED_TYPES=("sg" "vpc" "subnet" "aws_lb" "aws_lb_target_group" "ecr" "secretsmanager")

# Resource types filtered by ALB ARN (load_balancer_arn attribute)
ALB_ARN_FILTERED_TYPES=("aws_lb_listener" "aws_lb_listener_rule")

# Resource types filtered by VPC ID (vpc_id attribute)
VPC_ID_FILTERED_TYPES=("aws_network_interface" "route_table" "aws_internet_gateway" "aws_nat_gateway" "vpc_endpoint")

# Resource types filtered by VPC ID but also require a Name tag (to exclude AWS defaults)
VPC_ID_NAMED_FILTERED_TYPES=("nacl")

# Resource types included in full (no filtering)
INCLUDE_ALL_TYPES=("s3" "wafv2_regional")

# WAFv2 sub-types to exclude due to Terraformer bugs with incorrect ID format
WAFV2_EXCLUDE_TYPES=("aws_wafv2_web_acl_association")

# RDS cluster identifier to filter instances and subnet groups against
RDS_CLUSTER_ID="dsit-litellm-rds-pg-prod"

echo "================================================"
echo " Terraformer Plan + Filter"
echo " Resources: $RESOURCES"
echo " Region:    $REGION"
echo " Tag filter: $TAG_KEY = $TAG_VALUE"
echo "================================================"
echo ""

# ── Run regional plan first and save it ─────────────────────────────────────
echo "--- Running terraformer plan (regional resources) ---"
echo ""
terraformer plan aws --resources="$RESOURCES" --regions="$REGION"
if [ $? -ne 0 ]; then
  echo "Error: terraformer plan failed"
  exit 1
fi

if [ ! -f "$REGIONAL_PLAN_FILE" ]; then
  echo "Error: Regional plan file not found at $REGIONAL_PLAN_FILE"
  exit 1
fi

# Save a copy before IAM overwrites it
cp "$REGIONAL_PLAN_FILE" "$FILTERED_PLAN"
echo "Regional plan saved."
echo ""

# ── Run IAM plan separately and save to temp location ───────────────────────
echo "--- Running terraformer plan (IAM global resources) ---"
echo ""
terraformer plan aws --resources=iam
if [ $? -eq 0 ] && [ -f "$REGIONAL_PLAN_FILE" ]; then
  cp "$REGIONAL_PLAN_FILE" "$IAM_PLAN_FILE"
  echo "IAM plan saved."
else
  echo "Warning: IAM plan failed or file not found, skipping IAM resources."
  IAM_PLAN_FILE=""
fi
echo ""

TOTAL_MATCHED=0

# ── Step 1: Filter tag-based resources ──────────────────────────────────────
echo "--- Filtering by tag: $TAG_KEY = $TAG_VALUE ---"
echo ""

for resource_type in "${TAG_FILTERED_TYPES[@]}"; do
  exists=$(jq --arg rtype "$resource_type" '.ImportedResource | has($rtype)' "$FILTERED_PLAN")
  if [ "$exists" != "true" ]; then
    echo "[$resource_type] Not found in plan, skipping."
    continue
  fi

  before=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")

  tmp=$(mktemp)
  jq --arg key "tags.$TAG_KEY" --arg val "$TAG_VALUE" --arg rtype "$resource_type" '
    .ImportedResource[$rtype] |= map(
      select(.InstanceState.attributes[$key] == $val)
    )
  ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"

  after=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")
  echo "[$resource_type] $before found → $after matched"

  if [ "$after" -eq 0 ]; then
    echo "[$resource_type] Warning: no resources matched. Available tag keys:"
    jq -r --arg rtype "$resource_type" '[.ImportedResource[$rtype][].InstanceState.attributes | keys[] | select(startswith("tags."))] | unique[]' "$FILTERED_PLAN" | sed 's/^/    /'
  else
    echo "[$resource_type] Matched IDs:"
    jq -r --arg rtype "$resource_type" '.ImportedResource[$rtype][].InstanceState.id' "$FILTERED_PLAN" | sed 's/^/    /'
    TOTAL_MATCHED=$((TOTAL_MATCHED + after))
  fi
  echo ""
done

# ── Step 1b: ECS - filter cluster and service by tag, include task definitions in full ──
echo "--- Filtering ECS resources ---"
echo ""

exists=$(jq '.ImportedResource | has("ecs")' "$FILTERED_PLAN")
if [ "$exists" != "true" ]; then
  echo "[ecs] Not found in plan, skipping."
else
  before=$(jq '.ImportedResource.ecs | length' "$FILTERED_PLAN")

  tmp=$(mktemp)
  jq --arg key "tags.$TAG_KEY" --arg val "$TAG_VALUE" '
    .ImportedResource.ecs |= map(
      select(
        .InstanceInfo.Type == "aws_ecs_task_definition" or
        .InstanceState.attributes[$key] == $val
      )
    )
  ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"

  after=$(jq '.ImportedResource.ecs | length' "$FILTERED_PLAN")
  echo "[ecs] $before found → $after matched"
  echo "[ecs] Matched resources:"
  jq -r '.ImportedResource.ecs[] | "    \(.InstanceInfo.Type): \(.InstanceState.id)"' "$FILTERED_PLAN"
  TOTAL_MATCHED=$((TOTAL_MATCHED + after))
fi

echo ""

# ── Step 1c: RDS - filter by tag and cluster ID ──────────────────────────────
echo "--- Filtering RDS resources ---"
echo ""

exists=$(jq '.ImportedResource | has("rds")' "$FILTERED_PLAN")
if [ "$exists" != "true" ]; then
  echo "[rds] Not found in plan, skipping."
else
  before=$(jq '.ImportedResource.rds | length' "$FILTERED_PLAN")

  tmp=$(mktemp)
  jq --arg cluster_id "$RDS_CLUSTER_ID" --arg tag_key "tags.$TAG_KEY" --arg tag_val "$TAG_VALUE" '
    .ImportedResource.rds |= map(
      select(
        (.InstanceInfo.Type == "aws_rds_cluster" and .InstanceState.id == $cluster_id) or
        (.InstanceInfo.Type == "aws_db_instance" and .InstanceState.attributes[$tag_key] == $tag_val) or
        (.InstanceInfo.Type == "aws_db_subnet_group" and (.InstanceState.id | startswith("default") | not))
      )
    )
  ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"

  after=$(jq '.ImportedResource.rds | length' "$FILTERED_PLAN")
  echo "[rds] $before found → $after matched"
  echo "[rds] Matched resources:"
  jq -r '.ImportedResource.rds[] | "    \(.InstanceInfo.Type): \(.InstanceState.id)"' "$FILTERED_PLAN"
  TOTAL_MATCHED=$((TOTAL_MATCHED + after))
fi

echo ""

# ── Step 1d: IAM - filter by tag from separate global plan ───────────────────
echo "--- Filtering IAM resources ---"
echo ""

if [ -n "$IAM_PLAN_FILE" ] && [ -f "$IAM_PLAN_FILE" ]; then
  iam_exists=$(jq '.ImportedResource | has("iam")' "$IAM_PLAN_FILE")
  if [ "$iam_exists" != "true" ]; then
    echo "[iam] Not found in IAM plan, skipping."
  else
    before=$(jq '.ImportedResource.iam | length' "$IAM_PLAN_FILE")

    jq --arg key "tags.$TAG_KEY" --arg val "$TAG_VALUE" '
      .ImportedResource.iam |= map(
        select(.InstanceState.attributes[$key] == $val)
      )
    ' "$IAM_PLAN_FILE" > "$IAM_FILTERED_PLAN"

    after=$(jq '.ImportedResource.iam | length' "$IAM_FILTERED_PLAN")
    echo "[iam] $before found → $after matched"

    if [ "$after" -gt 0 ]; then
      echo "[iam] Matched IDs:"
      jq -r '.ImportedResource.iam[].InstanceState.id' "$IAM_FILTERED_PLAN" | sed 's/^/    /'
      TOTAL_MATCHED=$((TOTAL_MATCHED + after))
    fi
  fi
else
  echo "[iam] IAM plan file not found, skipping."
fi

echo ""

# ── Step 2: Extract matched VPC IDs ─────────────────────────────────────────
echo "--- Extracting matched VPC IDs ---"
echo ""

VPC_IDS=$(jq -r '.ImportedResource.vpc[]?.InstanceState.id // empty' "$FILTERED_PLAN")

if [ -z "$VPC_IDS" ]; then
  echo "[vpc] No matched VPCs found, skipping VPC-based filtering."
  echo ""
else
  echo "Matched VPC IDs:"
  echo "$VPC_IDS" | sed 's/^/    /'
  echo ""

  VPC_ARRAY=$(echo "$VPC_IDS" | jq -R . | jq -s .)

  # ── Step 3: Filter resources by VPC ID ──────────────────────────────────
  echo "--- Filtering by VPC ID ---"
  echo ""

  for resource_type in "${VPC_ID_FILTERED_TYPES[@]}"; do
    exists=$(jq --arg rtype "$resource_type" '.ImportedResource | has($rtype)' "$FILTERED_PLAN")
    if [ "$exists" != "true" ]; then
      echo "[$resource_type] Not found in plan, skipping."
      continue
    fi

    before=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")

    tmp=$(mktemp)
    jq --argjson vpcs "$VPC_ARRAY" --arg rtype "$resource_type" '
      .ImportedResource[$rtype] |= map(
        select(.InstanceState.attributes.vpc_id as $vid | $vpcs | index($vid) != null)
      )
    ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"

    after=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")
    echo "[$resource_type] $before found → $after matched"

    if [ "$after" -gt 0 ]; then
      echo "[$resource_type] Matched IDs:"
      jq -r --arg rtype "$resource_type" '.ImportedResource[$rtype][].InstanceState.id' "$FILTERED_PLAN" | sed 's/^/    /'
      TOTAL_MATCHED=$((TOTAL_MATCHED + after))
    fi
    echo ""
  done

  # ── Step 4: Filter NACLs by VPC ID and Name tag (excludes defaults) ──────
  echo "--- Filtering NACLs by VPC ID (excluding untagged defaults) ---"
  echo ""

  for resource_type in "${VPC_ID_NAMED_FILTERED_TYPES[@]}"; do
    exists=$(jq --arg rtype "$resource_type" '.ImportedResource | has($rtype)' "$FILTERED_PLAN")
    if [ "$exists" != "true" ]; then
      echo "[$resource_type] Not found in plan, skipping."
      continue
    fi

    before=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")

    tmp=$(mktemp)
    jq --argjson vpcs "$VPC_ARRAY" --arg rtype "$resource_type" '
      .ImportedResource[$rtype] |= map(
        select(
          (.InstanceState.attributes.vpc_id as $vid | $vpcs | index($vid) != null) and
          (.InstanceState.attributes["tags.Name"] != null)
        )
      )
    ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"

    after=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")
    echo "[$resource_type] $before found → $after matched (excluded untagged/default)"

    if [ "$after" -gt 0 ]; then
      echo "[$resource_type] Matched IDs:"
      jq -r --arg rtype "$resource_type" '.ImportedResource[$rtype][].InstanceState.id' "$FILTERED_PLAN" | sed 's/^/    /'
      TOTAL_MATCHED=$((TOTAL_MATCHED + after))
    fi
    echo ""
  done

  # ── Step 5: Extract matched ALB ARNs ──────────────────────────────────────
  echo "--- Extracting matched ALB ARNs ---"
  echo ""

  ALB_ARNS=$(jq -r '.ImportedResource.aws_lb[]?.InstanceState.attributes.arn // empty' "$FILTERED_PLAN")

  if [ -z "$ALB_ARNS" ]; then
    echo "[aws_lb] No matched ALBs found, skipping listener and rule filtering."
    echo ""
  else
    echo "Matched ALB ARNs:"
    echo "$ALB_ARNS" | sed 's/^/    /'
    echo ""

    ARN_ARRAY=$(echo "$ALB_ARNS" | jq -R . | jq -s .)

    # ── Step 6: Filter listeners and rules by ALB ARN ───────────────────────
    echo "--- Filtering listeners and rules by ALB ARN ---"
    echo ""

    for resource_type in "${ALB_ARN_FILTERED_TYPES[@]}"; do
      exists=$(jq --arg rtype "$resource_type" '.ImportedResource | has($rtype)' "$FILTERED_PLAN")
      if [ "$exists" != "true" ]; then
        echo "[$resource_type] Not found in plan, skipping."
        continue
      fi

      before=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")

      tmp=$(mktemp)
      jq --argjson arns "$ARN_ARRAY" --arg rtype "$resource_type" '
        .ImportedResource[$rtype] |= map(
          select(.InstanceState.attributes.load_balancer_arn as $arn | $arns | index($arn) != null)
        )
      ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"

      after=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")
      echo "[$resource_type] $before found → $after matched"

      if [ "$after" -gt 0 ]; then
        echo "[$resource_type] Matched IDs:"
        jq -r --arg rtype "$resource_type" '.ImportedResource[$rtype][].InstanceState.id' "$FILTERED_PLAN" | sed 's/^/    /'
        TOTAL_MATCHED=$((TOTAL_MATCHED + after))
      fi
      echo ""
    done
  fi
fi

# ── Step 7: Include all resources with no filtering ──────────────────────────
echo "--- Including all resources (no filter) ---"
echo ""

for resource_type in "${INCLUDE_ALL_TYPES[@]}"; do
  exists=$(jq --arg rtype "$resource_type" '.ImportedResource | has($rtype)' "$FILTERED_PLAN")
  if [ "$exists" != "true" ]; then
    echo "[$resource_type] Not found in plan, skipping."
    continue
  fi

  # Deduplicate by id
  tmp=$(mktemp)
  jq --arg rtype "$resource_type" '
    .ImportedResource[$rtype] |= (group_by(.InstanceState.id) | map(first))
  ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"

  # Remove known broken sub-types for wafv2_regional
  if [ "$resource_type" == "wafv2_regional" ]; then
    for exclude_type in "${WAFV2_EXCLUDE_TYPES[@]}"; do
      tmp=$(mktemp)
      jq --arg rtype "$resource_type" --arg etype "$exclude_type" '
        .ImportedResource[$rtype] |= map(select(.InstanceInfo.Type != $etype))
      ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"
      echo "[$resource_type] Excluded broken sub-type: $exclude_type"
    done
  fi

  count=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")
  echo "[$resource_type] $count resource(s) included"
  jq -r --arg rtype "$resource_type" '.ImportedResource[$rtype][].InstanceState.id' "$FILTERED_PLAN" | sed 's/^/    /'
  TOTAL_MATCHED=$((TOTAL_MATCHED + count))
  echo ""
done

# ── Final Step: Strip out any default resources across all types ─────────────
echo "--- Removing default resources ---"
echo ""

for resource_type in $(jq -r '.ImportedResource | keys[]' "$FILTERED_PLAN"); do
  if [[ "$resource_type" == aws_default_* ]]; then
    count=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")
    tmp=$(mktemp)
    jq --arg rtype "$resource_type" 'del(.ImportedResource[$rtype])' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"
    echo "[$resource_type] Removed entire resource type ($count resource(s))"
    TOTAL_MATCHED=$((TOTAL_MATCHED - count))
  fi
done

for resource_type in $(jq -r '.ImportedResource | keys[]' "$FILTERED_PLAN"); do
  before=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")

  tmp=$(mktemp)
  jq --arg rtype "$resource_type" '
    .ImportedResource[$rtype] |= map(
      select(.InstanceState.attributes.default != "true")
    )
  ' "$FILTERED_PLAN" > "$tmp" && mv "$tmp" "$FILTERED_PLAN"

  after=$(jq --arg rtype "$resource_type" '.ImportedResource[$rtype] | length' "$FILTERED_PLAN")
  removed=$((before - after))
  if [ "$removed" -gt 0 ]; then
    echo "[$resource_type] Removed $removed default resource(s)"
    TOTAL_MATCHED=$((TOTAL_MATCHED - removed))
  fi
done

echo ""
echo "================================================"

if [ "$TOTAL_MATCHED" -eq 0 ]; then
  echo "No resources matched. Nothing to import."
  exit 1
fi

echo "Total matched resources: $TOTAL_MATCHED"
echo "Running: terraformer import plan $FILTERED_PLAN"
echo "================================================"
terraformer import plan "$FILTERED_PLAN"

if [ -n "$IAM_PLAN_FILE" ] && [ -f "$IAM_FILTERED_PLAN" ] && [ "$(jq '.ImportedResource.iam | length' "$IAM_FILTERED_PLAN")" -gt 0 ]; then
  echo ""
  echo "Running: terraformer import plan $IAM_FILTERED_PLAN"
  terraformer import plan "$IAM_FILTERED_PLAN"
fi

echo ""
echo "Done."