resource "aws_sqs_queue" "this" {
  for_each = var.queues

  name                       = each.value.name
  fifo_queue                 = try(each.value.fifo, false)
  delay_seconds              = try(each.value.delay_seconds, 0)
  max_message_size           = try(each.value.max_message_size, 262144)
  message_retention_seconds  = try(each.value.message_retention_seconds, 345600)
  visibility_timeout_seconds = try(each.value.visibility_timeout_seconds, 30)

  sqs_managed_sse_enabled = each.value.kms_key_id == null ? true : null
  kms_master_key_id       = each.value.kms_key_id

  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_sqs_queue" "dlq" {
  for_each = { for k, v in var.queues : k => v if try(v.create_dlq, false) }

  name       = try(each.value.fifo, false) ? "${each.value.name}-dlq.fifo" : "${each.value.name}-dlq"
  fifo_queue = try(each.value.fifo, false)

  sqs_managed_sse_enabled = true

  tags = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_sqs_queue_redrive_policy" "this" {
  for_each = { for k, v in var.queues : k => v if try(v.create_dlq, false) }

  queue_url = aws_sqs_queue.this[each.key].url
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = try(each.value.max_receive_count, 3)
  })
}
