#!/usr/bin/env bash
# deploy.sh — Apply all generated Terraform modules in dependency order.
#
# All modules use an S3 backend. backend.hcl at the repo root supplies the
# bucket/region/dynamodb_table so those values live in one place.
#
# Prerequisites:
#   1. Copy backend.hcl.example -> backend.hcl and fill in real values.
#   2. Set TF_VAR_tf_state_bucket to the same bucket name (or source .env).
#   3. Run bootstrap/ once to create the S3 bucket and DynamoDB table.
#
# Dependency order:
#   Layer 1 (no deps):               vpc
#   Layer 2 (→ vpc):                 subnet, igw
#   Layer 3 (→ vpc/subnet):          sg, nacl, route_table, nat, eni, vpc_endpoint
#   Layer 4 (→ sg/subnet/alb/ecr):   alb, ecr, rds, ecs, iam, secretsmanager, s3, wafv2_regional
#
# Usage:
#   ./deploy.sh                     # plan + apply all (interactive approve)
#   ./deploy.sh --auto-approve      # non-interactive
#   ./deploy.sh --plan-only         # terraform plan only, no apply
#   ./deploy.sh --from <module>     # resume from a specific module
#   ./deploy.sh --only <module>     # apply one module only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GENERATED_DIR="$SCRIPT_DIR/generated/aws"
BACKEND_CONFIG="$SCRIPT_DIR/backend.hcl"
AUTO_APPROVE=""
PLAN_ONLY=false
FROM_MODULE=""
ONLY_MODULE=""

# ── Pre-flight checks ─────────────────────────────────────────────────────────
if [[ ! -f "$BACKEND_CONFIG" ]]; then
  echo "ERROR: backend.hcl not found at $BACKEND_CONFIG"
  echo "       Copy backend.hcl.example -> backend.hcl and fill in real values."
  exit 1
fi

if [[ -z "${TF_VAR_tf_state_bucket:-}" ]]; then
  echo "ERROR: TF_VAR_tf_state_bucket is not set."
  echo "       Source your .env file: set -a && source .env && set +a"
  exit 1
fi

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto-approve) AUTO_APPROVE="-auto-approve" ;;
    --plan-only)    PLAN_ONLY=true ;;
    --from)         FROM_MODULE="$2"; shift ;;
    --only)         ONLY_MODULE="$2"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# ── Ordered module list ───────────────────────────────────────────────────────
# Modules listed in strict dependency order so each state file exists
# before downstream modules attempt to read it via terraform_remote_state.
MODULES=(
  vpc                 # Layer 1 — no deps
  subnet              # Layer 2 — depends on: vpc
  igw                 # Layer 2 — depends on: vpc
  sg                  # Layer 3 — depends on: vpc
  nacl                # Layer 3 — depends on: vpc, subnet
  route_table         # Layer 3 — depends on: vpc, subnet
  nat                 # Layer 3 — depends on: subnet, igw (logical)
  eni                 # Layer 3 — depends on: subnet, sg (logical)
  vpc_endpoint        # Layer 3 — depends on: vpc, subnet (logical)
  alb                 # Layer 4 — depends on: sg, subnet
  ecr                 # Layer 4 — no remote state deps
  rds                 # Layer 4 — depends on: sg, subnet
  ecs                 # Layer 4 — depends on: sg, subnet
  iam                 # Layer 4 — no remote state deps
  secretsmanager      # Layer 4 — no remote state deps
  s3                  # Layer 4 — no remote state deps
  wafv2_regional      # Layer 4 — no remote state deps
)

# ── Helper ────────────────────────────────────────────────────────────────────
apply_module() {
  local module="$1"
  local dir="$GENERATED_DIR/$module"

  if [[ ! -d "$dir" ]]; then
    echo "WARNING: Skipping $module — directory not found at $dir"
    return 0
  fi

  echo ""
  echo "============================================================"
  echo "  Module: $module"
  echo "============================================================"

  pushd "$dir" > /dev/null

  echo "-> terraform init"
  terraform init -backend-config="$BACKEND_CONFIG" -input=false -no-color

  echo "-> terraform validate"
  terraform validate -no-color

  echo "-> terraform plan"
  terraform plan -no-color -out=tfplan.out

  if [[ "$PLAN_ONLY" == "false" ]]; then
    echo "-> terraform apply"
    # shellcheck disable=SC2086
    terraform apply -no-color $AUTO_APPROVE tfplan.out
    rm -f tfplan.out
  fi

  popd > /dev/null
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo "Deployment root: $GENERATED_DIR"
echo "Backend config:  $BACKEND_CONFIG"
echo "State bucket:    ${TF_VAR_tf_state_bucket}"
echo "Options: plan_only=$PLAN_ONLY auto_approve=${AUTO_APPROVE:-no}"

if [[ -n "$ONLY_MODULE" ]]; then
  apply_module "$ONLY_MODULE"
  exit 0
fi

SKIP=true
if [[ -z "$FROM_MODULE" ]]; then
  SKIP=false
fi

for module in "${MODULES[@]}"; do
  if [[ "$SKIP" == "true" && "$module" == "$FROM_MODULE" ]]; then
    SKIP=false
  fi

  if [[ "$SKIP" == "true" ]]; then
    echo "  (skipping $module — before --from $FROM_MODULE)"
    continue
  fi

  apply_module "$module"
done

echo ""
echo "============================================================"
echo "  Deployment complete"
echo "============================================================"
