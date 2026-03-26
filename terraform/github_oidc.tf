# ──────────────────────────────────────────────
# GitHub Actions OIDC → AWS IAM Role
# ──────────────────────────────────────────────
# This lets GitHub Actions assume an AWS role with no static keys.
# The role is scoped to a specific repo and branch.
# ──────────────────────────────────────────────

variable "github_org" {
  description = "GitHub org or username"
  type        = string
}

variable "github_repo" {
  description = "Repository name (without org prefix)"
  type        = string
}

# ── OIDC Identity Provider ──────────────────────

data "aws_iam_openid_connect_provider" "github" {
  count = 0 # set to 0; we create below. If you already have one, use data source instead.
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"] # GitHub's OIDC doesn't need real thumbprint validation

  tags = {
    Name = "github-actions-oidc"
  }
}

# ── IAM Role for GitHub Actions ────────────────

data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Lock to your specific repo — prod branch for apply, any branch for plan
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/prod",
        "repo:${var.github_org}/${var.github_repo}:pull_request",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name               = "github-actions-donnaspetcare-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json

  tags = {
    Name = "github-actions-deploy"
  }
}

# ── Permissions ────────────────────────────────

data "aws_iam_policy_document" "deploy_permissions" {

  # S3: site bucket — full control for sync
  statement {
    sid    = "SiteBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetEncryptionConfiguration",
      "s3:PutEncryptionConfiguration",
    ]
    resources = [
      "arn:aws:s3:::donnaspersonalpetcare.com",
      "arn:aws:s3:::donnaspersonalpetcare.com/*",
    ]
  }

  # S3: terraform state bucket
  statement {
    sid    = "TfStateBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::donnaspersonalpetcare-tf-state",
      "arn:aws:s3:::donnaspersonalpetcare-tf-state/*",
    ]
  }

  # S3: create site bucket (terraform)
  statement {
    sid       = "S3CreateBucket"
    effect    = "Allow"
    actions   = ["s3:CreateBucket"]
    resources = ["arn:aws:s3:::donnaspersonalpetcare.com"]
  }

  # CloudFront
  statement {
    sid    = "CloudFrontAccess"
    effect = "Allow"
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:UpdateDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:ListDistributions",
      "cloudfront:DeleteDistribution",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
      "cloudfront:ListTagsForResource",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:UpdateOriginAccessControl",
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:ListOriginAccessControls",
    ]
    resources = ["*"]
  }

  # ACM (us-east-1)
  statement {
    sid    = "ACMAccess"
    effect = "Allow"
    actions = [
      "acm:RequestCertificate",
      "acm:DescribeCertificate",
      "acm:DeleteCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate",
      "acm:AddTagsToCertificate",
    ]
    resources = ["*"]
  }

  # Route 53
  statement {
    sid    = "Route53Access"
    effect = "Allow"
    actions = [
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:ListResourceRecordSets",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*",
      "arn:aws:route53:::change/*",
    ]
  }

  statement {
    sid       = "Route53List"
    effect    = "Allow"
    actions   = ["route53:ListHostedZones"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name   = "deploy-permissions"
  role   = aws_iam_role.github_actions_deploy.id
  policy = data.aws_iam_policy_document.deploy_permissions.json
}

# ── Outputs ────────────────────────────────────

output "deploy_role_arn" {
  description = "Set this as GitHub Actions secret AWS_DEPLOY_ROLE_ARN"
  value       = aws_iam_role.github_actions_deploy.arn
}
