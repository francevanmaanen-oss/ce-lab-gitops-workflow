# GitOps Workflow Implementation Lab — M5.03

## Overview

This lab implements a two-environment GitOps workflow using GitHub Actions and Terraform. Git is the single source of truth: pushing to `develop` deploys to **dev**, merging to `main` deploys to **prod**. A scheduled drift detection workflow alerts the team if infrastructure is modified outside of Terraform.

---

## What Was Built

- Two long-lived branches: `main` (prod) and `develop` (dev)
- Terraform configuration for S3 buckets with environment-specific naming, tags, and settings
- A deploy workflow that targets dev on `develop` push and prod on `main` push
- A promotion flow: PR from `develop` to `main` runs a plan and deploys on merge
- A scheduled drift detection workflow

---

## Branch & Environment Strategy

| Branch | Environment | State File Key |
|--------|-------------|----------------|
| `develop` | dev | `m5-03-gitops/dev/terraform.tfstate` |
| `main` | prod | `m5-03-gitops/prod/terraform.tfstate` |

---

## Environment-Specific Configuration

| Setting | Dev | Prod |
|---------|-----|------|
| Versioning | Disabled | Enabled |
| Log retention | 7 days | 90 days |

---

## Promotion Flow

You never need to manually switch to `main`. The process is:

1. Make changes on `develop` and push
2. Dev deploy runs automatically via GitHub Actions
3. Open a PR from `develop` → `main` using `gh pr create`
4. The **Promotion Check** workflow runs and posts a Terraform plan comment on the PR
5. Review the plan, then merge — GitHub handles the branch update
6. The prod deploy triggers automatically on merge

---

## Errors Encountered & Fixes

### Error 1 — Expired GPG Key (Terraform Init failure)

**Symptom:**
Error: Failed to install provider
Error while installing hashicorp/aws v5.0.0: error checking signature:
openpgp: key expired
Terraform exited with code 1.

**Cause:**  
The lab's original Terraform version (`1.6.0`) uses an outdated HashiCorp GPG signing key that has since expired. Terraform verifies provider signatures on install, so the process fails entirely.

**Fix:**  
Bump the Terraform version to `1.9.0` or higher in all workflow files and in `main.tf`.

In `.github/workflows/deploy.yml` and `.github/workflows/promotion.yml`:

```yaml
env:
  TF_VERSION: "1.13.5"   # was "1.6.0"
```

In `main.tf`:

```hcl
terraform {
  required_version = ">= 1.9.0"   # was ">= 1.6.0"
}
```

---

### Error 2 — S3 Bucket Name Already Taken (Terraform Apply failure)

**Symptom:**
Error: creating Amazon S3 (Simple Storage) Bucket (gitops-lab-dev-data-store):
BucketAlreadyExists: The requested bucket name is not available.
The bucket namespace is shared by all users of the system.
Please select a different name and try again.
status code: 409

**Cause:**  
S3 bucket names are globally unique across **all** AWS accounts worldwide. The default bucket name `gitops-lab-dev-data-store` from the lab instructions was already claimed by another user (likely another bootcamp student using the same configuration).

**Fix:**  
Add a personal unique suffix to the bucket name in `main.tf`:

```hcl
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-${var.environment}-data-store-YOURNAME"
}
```

Replace `YOURNAME` with your own identifier (e.g. your username or initials).

---

### Warning — Deprecated `dynamodb_table` Backend Parameter

**Symptom:**
Warning: Deprecated Parameter
The parameter "dynamodb_table" is deprecated. Use parameter "use_lockfile" instead.

**Cause:**  
Newer versions of Terraform deprecated the `dynamodb_table` backend parameter in favour of native state locking via `use_lockfile`.

**Fix:**  
In the `backend "s3"` block in `main.tf`, replace:

```hcl
dynamodb_table = "terraform-locks"
```

with:

```hcl
use_lockfile = true
```
