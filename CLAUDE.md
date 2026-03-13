# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Monorepo of Terraform wrapper modules for AWS resources, designed for use with Terragrunt Catalog. Each module is independently versioned using git tags (`<module>-v<major>.<minor>.<patch>`, e.g. `s3-v1.0.0`). Pushing changes to `main` auto-increments the patch version for changed modules via `.github/workflows/release.yml`.

## Validation & Linting Commands

```bash
# Format check (all modules)
terraform fmt -check -recursive modules/

# Format fix
terraform fmt -recursive modules/

# Validate a specific module
cd modules/<name> && terraform init -backend=false && terraform validate

# Lint with TFLint (requires tflint installed with AWS plugin)
tflint --init && tflint --chdir=modules/<name>

# Security scans (as run in CI)
checkov -d modules/<name> -o sarif
trivy config modules/<name>
tfsec modules/<name>
```

There is no test suite — validation relies on `terraform validate`, TFLint, and the security scanners above.

## Module Architecture

All modules live under `modules/` and follow the same wrapper pattern:

- **Resource naming**: `resource "aws_<type>" "this"` with `for_each` over a map variable
- **Map variable**: each module exposes one map variable (`buckets`, `queues`, `secrets`) whose values are objects with required and optional fields using `optional()` types with defaults
- **Tag merging**: `merge(var.tags, try(each.value.tags, {}))` — common tags plus per-resource overrides
- **Outputs**: map-based (`bucket_ids`, `queue_arns`, etc.) keyed by the same keys as the input map
- **Conditional resources**: use map comprehensions (`{ for k, v in var.x : k => v if condition }`) to conditionally create related resources (e.g. DLQ for SQS)

Current modules: `s3`, `sqs`, `secret`.

## Adding a New Module

1. Create `modules/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`, `README.md`
2. Follow the wrapper pattern: single map variable with `for_each`, `"this"` resource alias, tag merging
3. Add `boilerplate.yml` in the module directory (can be empty `variables: []`)
4. The release workflow auto-detects new modules — no CI config changes needed

## Conventions

- **Terraform >= 1.9**
- **Commit messages**: `feat:`, `fix:` prefixes (conventional commits style)
- **Branch naming**: `feat/`, `fix/` prefixes — always create a new branch from `main` for new features or fixes; never commit directly to `main`
- **Terragrunt integration**: modules are sourced via `git::ssh://` URLs with tag refs; scaffolding templates live in `.boilerplate/`
