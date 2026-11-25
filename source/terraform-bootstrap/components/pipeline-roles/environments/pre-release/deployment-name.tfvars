# A plan and apply role pair for source/terraform in one pre-release account.
# Renaming the file later points it at fresh state.

environment       = "pre-release"
github_repository = "Home-Office-Digital/<repository-name>"

# Already in the account.
permissions_boundary_name = "<permissions-boundary-name>"
state_bucket_name         = "<pre-release-state-bucket-name>"

# Roles this creates. Use the same names in source/terraform/deployments.json.
plan_role_name  = "<plan-role-name>"
apply_role_name = "<apply-role-name>"

# The tags validation in variables.tf requires a non-empty value for each of its keys.
tags = {
  cost-centre      = ""
  account-code     = ""
  portfolio-id     = ""
  project-id       = ""
  service-id       = ""
  environment-type = ""
  owner-business   = ""
  budget-holder    = ""
  source-repo      = ""
  hosting-platform = ""
}
