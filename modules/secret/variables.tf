variable "tags" {
  description = "Common tags applied to all secrets"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of Secrets Manager secrets to create"
  type = map(object({
    name                    = string
    description             = optional(string)
    recovery_window_in_days = optional(number, 30)
    secret_string           = optional(string)
    kms_key_id              = optional(string)
    tags                    = optional(map(string), {})
  }))
}
