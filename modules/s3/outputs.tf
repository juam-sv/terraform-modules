output "bucket_ids" {
  description = "Map of bucket keys to their IDs"
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "bucket_arns" {
  description = "Map of bucket keys to their ARNs"
  value       = { for k, v in aws_s3_bucket.this : k => v.arn }
}
