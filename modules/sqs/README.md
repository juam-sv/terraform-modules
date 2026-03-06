# SQS Wrapper Module

This module creates one or multiple SQS queues using a `for_each` map.

## Features

* Standard and FIFO queue support.
* Optional dead-letter queue (DLQ) with redrive policy.
* Merged global and local tags.

## Usage via Catalog

Run `terragrunt catalog` and select this module to scaffold your configuration.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `queues` | Map of SQS queues to create | `map(object({...}))` | — | yes |
| `tags` | Common tags applied to all queues | `map(string)` | `{}` | no |

### `queues` object

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `name` | `string` | — | Queue name |
| `fifo` | `bool` | `false` | Create as FIFO queue |
| `delay_seconds` | `number` | `0` | Delivery delay in seconds |
| `max_message_size` | `number` | `262144` | Max message size in bytes |
| `message_retention_seconds` | `number` | `345600` | Message retention period |
| `visibility_timeout_seconds` | `number` | `30` | Visibility timeout |
| `create_dlq` | `bool` | `false` | Create a dead-letter queue |
| `max_receive_count` | `number` | `3` | Max receives before sending to DLQ |
| `tags` | `map(string)` | `{}` | Per-queue tags (merged with global) |

## Outputs

| Name | Description |
|------|-------------|
| `queue_urls` | Map of queue keys to their URLs |
| `queue_arns` | Map of queue keys to their ARNs |
| `dlq_arns` | Map of DLQ keys to their ARNs |
