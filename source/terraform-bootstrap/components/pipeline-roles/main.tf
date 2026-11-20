# The plan and apply roles that source/terraform deploys with. What they may do
# is defined in plan-policy.tf and apply-policy.tf.

data "aws_caller_identity" "current" {}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  repo_name    = split("/", var.github_repository)[1]
  boundary_arn = "arn:aws:iam::${local.account_id}:policy/${var.permissions_boundary_name}"

  # Product state is <repo>/* in the default workspace and env:<repo>/* in
  # ephemeral ones. This folder's state also sits under <repo>/, so it's
  # denied explicitly: the roles must not be able to edit their own grants.
  state_bucket_arn = "arn:aws:s3:::${var.state_bucket_name}"
  state            = ["${local.state_bucket_arn}/${local.repo_name}/*", "${local.state_bucket_arn}/env:${local.repo_name}/*"]
  state_locks      = [for arn in local.state : "${arn}.tflock"]
  own_state        = ["${local.state_bucket_arn}/${local.repo_name}/source/terraform-bootstrap/*"]

  plan_subjects = ["repo:${var.github_repository}:*"]
  apply_subjects = concat(
    ["repo:${var.github_repository}:environment:${var.environment}"],
    var.apply_from_default_branch ? ["repo:${var.github_repository}:ref:refs/heads/main"] : [],
  )
}

module "plan_role" {
  source = "git::https://github.com/Home-Office-Digital/core-cloud-iam-role-tf-module.git?ref=5f4a231fa67a4093e95d4014b44784c851f663aa" # 0.2.8

  name                 = var.plan_role_name
  use_name_prefix      = false
  description          = "Plans ${var.github_repository} source/terraform in ${var.environment}. Read-only, plus the state lock."
  permissions_boundary = local.boundary_arn

  # Any ref: plan runs on pull requests, pushes, releases and dispatches.
  enable_github_oidc     = true
  oidc_wildcard_subjects = local.plan_subjects

  create_inline_policy           = true
  source_inline_policy_documents = [data.aws_iam_policy_document.plan.json]

  tags = var.tags
}

module "apply_role" {
  source = "git::https://github.com/Home-Office-Digital/core-cloud-iam-role-tf-module.git?ref=5f4a231fa67a4093e95d4014b44784c851f663aa" # 0.2.8

  name                 = var.apply_role_name
  use_name_prefix      = false
  description          = "Applies ${var.github_repository} source/terraform in ${var.environment}."
  permissions_boundary = local.boundary_arn

  # The approval-gated apply job's GitHub Environment, plus main where
  # apply_from_default_branch is set.
  enable_github_oidc = true
  oidc_subjects      = local.apply_subjects

  create_inline_policy           = true
  source_inline_policy_documents = [data.aws_iam_policy_document.apply.json]

  tags = var.tags
}
