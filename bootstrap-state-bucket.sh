#!/usr/bin/env bash
# bootstrap-state-bucket.sh — run ONCE before `terraform init`
set -euo pipefail

BUCKET="donnaspersonalpetcare-tf-state"
REGION="us-east-1"

echo "→ Creating state bucket: $BUCKET"
aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "✓ State bucket ready. Run: terraform init"
