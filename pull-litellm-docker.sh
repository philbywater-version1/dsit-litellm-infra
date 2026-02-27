#!/bin/bash
# =============================================================
# update-litellm.sh
# Copies the latest LiteLLM stable image (linux/amd64) from
# ghcr.io directly to ECR using crane, then forces a new ECS
# service deployment.
#
# Prerequisites:
#   brew install crane
#   AWS CLI configured with ECR + ECS permissions
# =============================================================

set -euo pipefail

# --- Configuration -------------------------------------------
AWS_REGION="eu-west-2"
AWS_ACCOUNT_ID="072136646002"
ECR_REPO="litellm"
IMAGE_TAG="main-stable"
UPSTREAM_IMAGE="ghcr.io/berriai/litellm:${IMAGE_TAG}"
ECS_CLUSTER="dsit-llmlite-gateway-main-cluster-fg"
ECS_SERVICE="litellm"
# -------------------------------------------------------------

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_URI="${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"

echo "====================================================="
echo " LiteLLM Image Update & ECS Redeployment"
echo "====================================================="
echo "  Upstream : ${UPSTREAM_IMAGE}"
echo "  ECR      : ${ECR_URI}"
echo "  Cluster  : ${ECS_CLUSTER}"
echo "  Service  : ${ECS_SERVICE}"
echo "====================================================="

# Check crane is installed
if ! command -v crane &> /dev/null; then
  echo ""
  echo "ERROR: 'crane' is not installed. Run: brew install crane"
  exit 1
fi

# Step 1 — Authenticate crane with ECR
echo ""
echo "[1/3] Authenticating with ECR..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | crane auth login "${ECR_REGISTRY}" \
    --username AWS \
    --password-stdin

# Step 2 — Copy linux/amd64 image directly from ghcr.io to ECR
# crane handles multi-platform manifests cleanly — no local pull needed
echo ""
echo "[2/3] Copying linux/amd64 image from ghcr.io to ECR..."
crane copy \
  --platform linux/amd64 \
  "${UPSTREAM_IMAGE}" \
  "${ECR_URI}"

echo "     ✓ Image copied successfully"

# Step 3 — Force new ECS deployment
echo ""
echo "[3/3] Forcing new ECS service deployment..."
DEPLOY_STATUS=$(aws ecs update-service \
  --cluster "${ECS_CLUSTER}" \
  --service "${ECS_SERVICE}" \
  --force-new-deployment \
  --region "${AWS_REGION}" \
  --output text \
  --query 'service.deployments[0].status')

echo "     ✓ Deployment status: ${DEPLOY_STATUS}"

echo ""
echo "====================================================="
echo " Done! New deployment triggered."
echo " Monitor progress:"
echo " aws ecs describe-services \\"
echo "   --cluster ${ECS_CLUSTER} \\"
echo "   --services ${ECS_SERVICE} \\"
echo "   --region ${AWS_REGION} \\"
echo "   --query 'services[0].deployments'"
echo "====================================================="