variable "tags" {
  description = "Common tags applied to all buckets"
  type        = map(string)
  default     = {}
}

variable "buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    name                  = string
    versioning_enabled    = optional(bool, false)
    kms_key_id            = optional(string)
    logging_target_bucket = optional(string)
    logging_target_prefix = optional(string, "")
    tags                  = optional(map(string), {})
  }))
}
