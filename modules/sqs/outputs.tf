output "queue_urls" {
  description = "Map of queue keys to their URLs"
  value       = { for k, v in aws_sqs_queue.this : k => v.url }
}

output "queue_arns" {
  description = "Map of queue keys to their ARNs"
  value       = { for k, v in aws_sqs_queue.this : k => v.arn }
}

output "dlq_arns" {
  description = "Map of DLQ keys to their ARNs"
  value       = { for k, v in aws_sqs_queue.dlq : k => v.arn }
}
