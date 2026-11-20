variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment this deployment targets. Matches the environments/<env>/ folder and the GitHub Environment that gates apply."
  type        = string

  validation {
    condition     = contains(["development", "pre-release", "release"], var.environment)
    error_message = "environment must be one of: development, pre-release, release."
  }
}

variable "plan_role_name" {
  description = "Name of the product plan role. Put the same name in source/terraform/deployments.json."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.plan_role_name))
    error_message = "plan_role_name must be a valid IAM role name of up to 64 characters."
  }
}

variable "apply_role_name" {
  description = "Name of the product apply role. Put the same name in source/terraform/deployments.json."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.apply_role_name))
    error_message = "apply_role_name must be a valid IAM role name of up to 64 characters."
  }
}

variable "permissions_boundary_name" {
  description = "Name of the permissions boundary policy required on roles created in this account."
  type        = string
}

variable "state_bucket_name" {
  description = "State bucket both folders use in this account. Matches state_bucket_name in both deployments.json files."
  type        = string
}

variable "github_repository" {
  description = "Repository whose workflows may assume the roles, as <owner>/<repo>."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$", var.github_repository))
    error_message = "github_repository must be <owner>/<repo>."
  }
}

variable "apply_from_default_branch" {
  description = "Also let the default branch assume the apply role. Set in the environment that hosts ephemeral deploys: cleanup runs from main without a GitHub Environment."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to both roles. The validation below lists the required keys."
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
