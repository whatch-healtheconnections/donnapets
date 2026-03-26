variable "aws_region" {
  description = "Primary AWS region for S3 and other resources"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
  default     = "donnaspersonalpetcare.com"
}

variable "site_bucket_name" {
  description = "S3 bucket name for the static site"
  type        = string
  default     = "donnaspersonalpetcare.com"
}

locals {
  s3_origin_id = "S3-${var.site_bucket_name}"
}
