variable "tags" {
  description = "Common tags applied to all queues"
  type        = map(string)
  default     = {}
}

variable "queues" {
  description = "Map of SQS queues to create"
  type = map(object({
    name                       = string
    fifo                       = optional(bool, false)
    delay_seconds              = optional(number, 0)
    max_message_size           = optional(number, 262144)
    message_retention_seconds  = optional(number, 345600)
    visibility_timeout_seconds = optional(number, 30)
    create_dlq                 = optional(bool, false)
    max_receive_count          = optional(number, 3)
    tags                       = optional(map(string), {})
  }))
}
