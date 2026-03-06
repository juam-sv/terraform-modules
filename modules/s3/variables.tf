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
