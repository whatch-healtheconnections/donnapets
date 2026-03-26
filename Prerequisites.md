# Prerequisites & Manual Steps Plan

## Overview

There's a bootstrap ordering problem here: GitHub Actions needs an IAM role to run
Terraform, but that IAM role is itself defined in Terraform. So we do the first pass
locally, then hand off to CI/CD for everything after.

---

## Phase 1: One-Time Manual Setup (Local Machine)

### 1.1 — AWS Account & CLI

- [ ] AWS CLI installed and configured with a profile that has admin (or broad IAM/S3/Route53) permissions
- [ ] Verify the Route 53 hosted zone for `donnaspersonalpetcare.com` exists:
  ```bash
  aws route53 list-hosted-zones --query "HostedZones[?Name=='donnaspersonalpetcare.com.']"
  ```
- [ ] If the domain was registered outside AWS, make sure the registrar's nameservers
      point to the NS records in the Route 53 hosted zone

### 1.2 — Create the Terraform State Bucket

```bash
./bootstrap-state-bucket.sh
```

This creates `donnaspersonalpetcare-tf-state` with versioning and public access blocked.

### 1.3 — First Terraform Apply (Local)

This creates everything: S3 site bucket, ACM cert, CloudFront, Route 53 records,
**and** the GitHub OIDC provider + IAM role.

```bash
cd terraform
terraform init
terraform apply
```

You'll be prompted for `github_org` and `github_repo`. Alternatively, create a
`terraform.tfvars`:

```hcl
github_org  = "your-github-username-or-org"
github_repo = "donnaspersonalpetcare"
```

**This apply will take ~10-15 min** (CloudFront propagation + ACM DNS validation).

When it completes, grab the output:

```
deploy_role_arn = "arn:aws:iam::XXXXXXXXXXXX:role/github-actions-donnaspetcare-deploy"
cloudfront_distribution_id = "EXXXXXXXXXX"
```

### 1.4 — Set GitHub Actions Secrets

Go to **GitHub → repo → Settings → Secrets and variables → Actions** and add:

| Secret Name                    | Value                                        |
|-------------------------------|----------------------------------------------|
| `AWS_DEPLOY_ROLE_ARN`         | The `deploy_role_arn` output from step 1.3    |
| `CLOUDFRONT_DISTRIBUTION_ID`  | The `cloudfront_distribution_id` output       |

---

## Phase 2: GitHub Repo Setup

### 2.1 — Branch Structure

- [ ] Create a `prod` branch if it doesn't exist
- [ ] Set `prod` as a protected branch (require PR, no force push)
- [ ] Workflows trigger on merge to `prod`

### 2.2 — Repo File Layout

```
├── .github/
│   └── workflows/
│       ├── deploy.yml          # SPA deploy on merge to prod
│       └── infra.yml           # Terraform plan on PR, apply on merge
├── terraform/
│   ├── providers.tf
│   ├── variables.tf
│   ├── acm.tf
│   ├── s3.tf
│   ├── cloudfront.tf
│   ├── route53_zone.tf
│   ├── route53_records.tf
│   ├── github_oidc.tf
│   ├── outputs.tf
│   ├── deploy-site.sh
│   └── bootstrap-state-bucket.sh
├── index.html                  # SPA files at repo root (or src/, dist/, etc.)
└── ...
```

### 2.3 — Adjust `deploy.yml`

Edit the `SITE_DIR` env var and the `--exclude` flags in `deploy.yml` to match
your actual SPA structure. If you have a build step (npm/vite/etc.), uncomment
the build steps in the workflow.

---

## Phase 3: Verify End-to-End

- [ ] Push an initial commit to `prod` with a test `index.html`
- [ ] Confirm the deploy workflow runs and succeeds in **Actions** tab
- [ ] Verify `https://donnaspersonalpetcare.com` serves the page with a valid cert
- [ ] Verify `https://www.donnaspersonalpetcare.com` also works
- [ ] Verify `http://` redirects to `https://`

---

## What Does NOT Need a GitHub "User"

You don't need to create a separate GitHub user or bot account. The OIDC federation
in `github_oidc.tf` lets GitHub Actions assume the AWS IAM role directly using
short-lived tokens — no static AWS keys, no service accounts, no PATs. The trust
relationship is scoped to your specific repo and branch.

The only GitHub-side config is the two repository secrets in step 1.4.

---

## Ongoing Workflow

| Change type        | What to do                                         |
|--------------------|----------------------------------------------------|
| Site content/code  | PR → merge to `prod` → `deploy.yml` syncs S3       |
| Infra changes      | Edit `terraform/` → PR (shows plan) → merge → apply |
| New domain/cert    | Update `variables.tf` + `cloudfront.tf` → same flow |