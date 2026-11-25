locals {
  # Ephemeral deploys run in a pr-<n>-<deployment-name> workspace in the same
  # account, so the workspace name is added to names that must be unique.
  workspace_suffix = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  name_prefix      = "${var.project_name}-${var.environment}${local.workspace_suffix}"
}

data "aws_caller_identity" "current" {}
