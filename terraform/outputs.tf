output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (use for cache invalidation)"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket for uploading site files"
  value       = aws_s3_bucket.site.id
}

output "site_url" {
  description = "Live site URL"
  value       = "https://${var.domain_name}"
}
