#!/usr/bin/env bash
# deploy-site.sh — sync local site files to S3 and invalidate CloudFront cache
# Usage: ./deploy-site.sh <path-to-site-dir>
set -euo pipefail

SITE_DIR="${1:?Usage: $0 <path-to-site-dir>}"
BUCKET=$(terraform -chdir="$(dirname "$0")" output -raw s3_bucket_name)
DIST_ID=$(terraform -chdir="$(dirname "$0")" output -raw cloudfront_distribution_id)

echo "→ Syncing $SITE_DIR to s3://$BUCKET ..."
aws s3 sync "$SITE_DIR" "s3://$BUCKET" --delete

echo "→ Invalidating CloudFront cache ($DIST_ID) ..."
aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*" --no-cli-pager

echo "✓ Deployed to https://$(terraform -chdir="$(dirname "$0")" output -raw site_url | sed 's|https://||')"
