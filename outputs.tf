output "bucket_name" {
  description = "Name of the data store bucket"
  value       = aws_s3_bucket.data.id
}
 
output "bucket_arn" {
  description = "ARN of the data store bucket"
  value       = aws_s3_bucket.data.arn
}
 
output "environment" {
  description = "Active environment"
  value       = var.environment
}
 
output "versioning_status" {
  description = "Bucket versioning status"
  value       = var.enable_versioning ? "Enabled" : "Suspended"
}