variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "gitops-lab"
}

variable "environment" {
  description = "Target environment (dev or prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Days to retain access logs"
  type        = number
  default     = 30
}