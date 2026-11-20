# A plan and apply role pair for source/terraform in one development account.
# Renaming the file later points it at fresh state.

environment       = "development"
github_repository = "Home-Office-Digital/<repository-name>"

# Already in the account.
permissions_boundary_name = "<permissions-boundary-name>"
state_bucket_name         = "<development-state-bucket-name>"

# Roles this creates. Use the same names in source/terraform/deployments.json.
plan_role_name  = "<plan-role-name>"
apply_role_name = "<apply-role-name>"

# Ephemeral deploys run in development, and their cleanup runs from main
# without a GitHub Environment, so main may also assume the apply role here.
apply_from_default_branch = true

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
