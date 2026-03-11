# Proof of Concept Specification: Terraform Multi-Tag Monorepo

**Author:** Juam

**Target Repository:** `https://github.com/juam-sv/terraform-modules`

**Status:** Draft / Blueprint

**Objective:** Establish a scalable Terraform module monorepo utilizing independent multi-tag versioning, the wrapper pattern for multi-resource creation, and Terragrunt Catalog for developer self-service and scaffolding.

---

## 1. Repository Structure
The repository will follow a flat module structure, segregating CI/CD logic, scaffolding boilerplates, and the Terraform modules themselves.



```text
terraform-modules/
├── .github/
│   └── workflows/
│       └── release.yml          # Multi-tag CI/CD pipeline
├── .boilerplate/
│   └── terragrunt.hcl.tmpl      # Scaffolding template for Terragrunt Catalog
├── modules/
│   ├── s3/
│   │   ├── main.tf              # Implements the Wrapper Pattern
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md            # Parsed by Terragrunt Catalog
│   ├── sqs/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── secret/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
└── README.md                    # Root documentation for Catalog usage
```

---

## 2. Module Design: The Wrapper Pattern
To avoid WET (Write Everything Twice) code in the live repository, each module will act as a wrapper, utilizing `for_each` at the resource level to accept a map of resources.

### Example: `modules/s3/main.tf`
This allows the creation of multiple buckets from a single module call.

```hcl
resource "aws_s3_bucket" "this" {
  for_each = var.buckets

  bucket = each.value.name
  tags   = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = { for k, v in var.buckets : k => v if try(v.versioning_enabled, false) }

  bucket = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}
```

### Example: `modules/s3/variables.tf`
```hcl
variable "tags" {
  description = "Common tags applied to all buckets"
  type        = map(string)
  default     = {}
}

variable "buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    name               = string
    versioning_enabled = optional(bool, false)
    tags               = optional(map(string), {})
  }))
}
```

---

## 3. CI/CD Pipeline: Multi-Tag Approach
The GitHub Actions workflow detects which specific directories inside `modules/` have changed, validates them, and pushes an independent tag (e.g., `s3-v1.0.0`) upon merging to `main`.



### `.github/workflows/release.yml`
```yaml
name: Module Release (Multi-Tag)

on:
  push:
    branches:
      - main
    paths:
      - 'modules/**'

jobs:
  detect-and-tag:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get changed modules
        id: changes
        uses: tj-actions/changed-files@v44
        with:
          dir_names: true
          dir_names_max_depth: 2
          files: modules/**

      - name: Tag Changed Modules
        if: steps.changes.outputs.any_changed == 'true'
        run: |
          for MODULE_PATH in ${{ steps.changes.outputs.all_changed_files }}; do
            # Extract module name (e.g., 's3' from 'modules/s3')
            MODULE_NAME=$(basename $MODULE_PATH)
            
            # Find latest tag for this module
            LATEST_TAG=$(git tag -l "$MODULE_NAME-v*" --sort=-v:refname | head -n 1)
            
            if [ -z "$LATEST_TAG" ]; then
              NEW_TAG="$MODULE_NAME-v1.0.0"
            else
              # Increment patch version (simplified logic)
              VERSION=$(echo $LATEST_TAG | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
              BASE=$(echo $VERSION | cut -d. -f1-2)
              PATCH=$(echo $VERSION | cut -d. -f3)
              NEW_TAG="$MODULE_NAME-v$BASE.$((PATCH + 1))"
            fi
            
            echo "Applying tag $NEW_TAG to $MODULE_NAME"
            git tag $NEW_TAG
            git push origin $NEW_TAG
          done
```

---

## 4. Live Environment: Terragrunt Input Example
This is how the external "Live" repository consumes the multi-tag monorepo, utilizing the wrapper pattern to pass multiple resources at once.

### `live/prod/us-east-1/s3/terragrunt.hcl`
```hcl
terraform {
  # Points to the specific module and the specific multi-tag version
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

---

## 5. Developer Experience: Terragrunt Catalog & Scaffolding

To provide a self-service experience, we integrate Terragrunt Catalog. Engineers use the CLI to browse the monorepo, read the documentation, and scaffold the `terragrunt.hcl` files automatically.

### Boilerplate Template (`.boilerplate/terragrunt.hcl.tmpl`)
This file dictates how the scaffolded code will look when an engineer selects a module from the TUI.

```hcl
terraform {
  source = "git::ssh://git@github.com/juam-sv/terraform-modules.git//{{ .ModulePath }}?ref={{ .Tag }}"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  # TODO: Fill in required inputs
}
```

### Module Documentation (`modules/s3/README.md`)
The Catalog extracts the description directly from the module's README.

```markdown
# S3 Wrapper Module

This module creates one or multiple S3 buckets using a `for_each` map. 

## Features
* Toggleable versioning per bucket.
* Merged global and local tags.

## Usage via Catalog
Run `terragrunt catalog` and select this module to scaffold your configuration.
```

### Root Instructions (`README.md`)
Instructions for the engineering team on how to use the portal.

```markdown
# Infrastructure Modules Monorepo

Welcome to the Terraform modules registry. 

## How to use the Catalog (TUI)
You do not need to manually create `terragrunt.hcl` files or search for the latest module tags. Use the built-in catalog:

1. Navigate to your target environment in the **live** repository (e.g., `cd prod/us-east-1/`).
2. Run the catalog command pointing to this monorepo:
   ```bash
   terragrunt catalog github.com/juam-sv/terraform-modules
   ```
3. **Search & Select:** Use the arrow keys to browse `s3`, `sqs`, or `secret`.
4. **Scaffold:** Press `S` to scaffold the module. Terragrunt will create the `terragrunt.hcl` file with the correct `source`, the latest tag, and the boilerplate inputs.
```
