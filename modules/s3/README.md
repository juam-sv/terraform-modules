# S3 Wrapper Module

This module creates one or multiple S3 buckets using a `for_each` map.

## Features

* Toggleable versioning per bucket.
* Merged global and local tags.

## Usage via Catalog

Run `terragrunt catalog` and select this module to scaffold your configuration.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `buckets` | Map of S3 buckets to create | `map(object({...}))` | — | yes |
| `tags` | Common tags applied to all buckets | `map(string)` | `{}` | no |

### `buckets` object

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `name` | `string` | — | Bucket name |
| `versioning_enabled` | `bool` | `false` | Enable versioning |
| `tags` | `map(string)` | `{}` | Per-bucket tags (merged with global) |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_ids` | Map of bucket keys to their IDs |
| `bucket_arns` | Map of bucket keys to their ARNs |
