terraform {
  required_version = ">= 1.13.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.0"
    }
  }

  backend "s3" {
    bucket       = "ce-bootcamp-tfstate-francevanmaanen-gitops"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
    # key is set dynamically via -backend-config in the workflow
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-${var.environment}-data-store"

  tags = {
    Name        = "${var.project_name}-${var.environment}-data-store"
    Environment = var.environment
    ManagedBy   = "terraform"
    GitOps      = "true"
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    expiration {
      days = var.log_retention_days
    }

    filter {
      prefix = "logs/"
    }
  }
}