# Add Variables Here #

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "managed_secrets" {
  description = "Secrets to create in AWS Secrets Manager. mode can be empty or generated."
  type = map(object({
    description                      = optional(string)
    secret_name                      = optional(string)
    kms_key_id                       = optional(string)
    recovery_window_in_days          = optional(number, 30)
    mode                             = optional(string, "empty")
    random_password_length           = optional(number, 32)
    random_password_special          = optional(bool, true)
    random_password_override_special = optional(string, "!#$%&*()-_=+[]{}<>:?")
    secret_string_template           = optional(map(string), {})
    tags                             = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for cfg in values(var.managed_secrets) : contains(["empty", "generated"], try(cfg.mode, "empty"))
    ])
    error_message = "managed_secrets mode must be either empty or generated."
  }
}

variable "existing_secret_names" {
  description = "Existing Secrets Manager secret names to retrieve for reuse in other resources."
  type        = set(string)
  default     = []
}

variable "example_rds_secret_name" {
  description = "Optional existing secret name to decode as an RDS-style { username, password } payload."
  type        = string
  default     = null
  nullable    = true
}
