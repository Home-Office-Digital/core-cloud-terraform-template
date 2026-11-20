locals {
  # Ephemeral deploys run in a pr-<n>-<deployment-name> workspace in the same
  # account, so the workspace name is added to names that must be unique.
  workspace_suffix = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  name_prefix      = "${var.project_name}-${var.environment}${local.workspace_suffix}"
}

data "aws_caller_identity" "current" {}

module "s3" {
  source = "git::https://github.com/Home-Office-Digital/core-cloud-s3-tf-module.git?ref=1.1.0"

  project_name  = var.project_name
  environment   = var.environment
  bucket_name   = "example${local.workspace_suffix}"
  kms_alias     = "${local.name_prefix}-s3"
  account_id    = data.aws_caller_identity.current.account_id
  region        = var.aws_region
  email_address = var.notification_email
  tags          = var.tags
}
