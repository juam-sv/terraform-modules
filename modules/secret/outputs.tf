output "secret_ids" {
  description = "Map of secret keys to their IDs"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.id }
}

output "secret_arns" {
  description = "Map of secret keys to their ARNs"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}
