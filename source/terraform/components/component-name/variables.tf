# Put values shared by every deployment in the defaults here. Each
# environments/<environment-name>/<deployment-name>.tfvars sets only what differs.

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment this deployment targets. Matches the environments/<env>/ folder."
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod."
  }
}

variable "project_name" {
  description = "Short project name, used as the prefix for resource names."
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource. See the CC Tagging Strategy for the required keys."
  type        = map(string)

  validation {
    condition = alltrue([
      for key in [
        "cost-centre", "account-code", "portfolio-id", "project-id", "service-id",
        "environment-type", "owner-business", "budget-holder", "source-repo", "hosting-platform",
      ] : trimspace(lookup(var.tags, key, "")) != ""
    ])
    error_message = "Every mandatory tag must be set to a non-empty value."
  }
}

variable "notification_email" {
  description = "Shared project mailbox subscribed to the example bucket's S3 event topic."
  type        = string
}
