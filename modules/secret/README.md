# Secret Wrapper Module

This module creates one or multiple AWS Secrets Manager secrets using a `for_each` map.

## Features

* Configurable recovery window per secret.
* Optional initial secret value.
* Merged global and local tags.

## Usage via Catalog

Run `terragrunt catalog` and select this module to scaffold your configuration.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `secrets` | Map of Secrets Manager secrets to create | `map(object({...}))` | — | yes |
| `tags` | Common tags applied to all secrets | `map(string)` | `{}` | no |

### `secrets` object

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `name` | `string` | — | Secret name |
| `description` | `string` | `null` | Secret description |
| `recovery_window_in_days` | `number` | `30` | Days before permanent deletion |
| `secret_string` | `string` | `null` | Initial secret value |
| `tags` | `map(string)` | `{}` | Per-secret tags (merged with global) |

## Outputs

| Name | Description |
|------|-------------|
| `secret_ids` | Map of secret keys to their IDs |
| `secret_arns` | Map of secret keys to their ARNs |
