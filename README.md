# Infrastructure Modules Monorepo

[![Module Release (Multi-Tag)](https://github.com/juam-sv/terraform-modules/actions/workflows/release.yml/badge.svg)](https://github.com/juam-sv/terraform-modules/actions/workflows/release.yml)

Welcome to the Terraform modules registry. This monorepo contains reusable Terraform modules using the **Wrapper Pattern** with independent **multi-tag versioning**.

## Available Modules

| Module | Description |
|--------|-------------|
| [s3](modules/s3/) | Create multiple S3 buckets with optional versioning |
| [sqs](modules/sqs/) | Create multiple SQS queues with optional FIFO and DLQ |
| [secret](modules/secret/) | Create multiple Secrets Manager secrets |

## How to use the Catalog (TUI)

You do not need to manually create `terragrunt.hcl` files or search for the latest module tags. Use the built-in catalog:

1. Navigate to your target environment in the **live** repository (e.g., `cd prod/us-east-1/`).
2. Run the catalog command pointing to this monorepo:
   ```bash
   terragrunt catalog github.com/juam-sv/terraform-modules
   ```
3. **Search & Select:** Use the arrow keys to browse `s3`, `sqs`, or `secret`.
4. **Scaffold:** Press `S` to scaffold the module. Terragrunt will create the `terragrunt.hcl` file with the correct `source`, the latest tag, and the boilerplate inputs.

## Live Environment Example

This is how the external "Live" repository consumes the modules using the wrapper pattern to pass multiple resources at once.

### `live/prod/us-east-1/s3/terragrunt.hcl`

```hcl
terraform {
  source = "git::ssh://git@github.com/juam-sv/terraform-modules.git//modules/s3?ref=s3-v1.0.0"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  tags = {
    Environment = "prod"
    ManagedBy   = "terragrunt"
  }

  buckets = {
    app_assets = {
      name               = "juam-prod-app-assets"
      versioning_enabled = true
    }
    app_logs = {
      name               = "juam-prod-app-logs"
      versioning_enabled = false
      tags = {
        Retention = "30-days"
      }
    }
  }
}
```

## Versioning

Each module is tagged independently using the format `<module>-v<major>.<minor>.<patch>` (e.g., `s3-v1.0.0`, `sqs-v1.2.3`). Tags are automatically applied by the CI/CD pipeline when changes to a module are merged into `main`.
