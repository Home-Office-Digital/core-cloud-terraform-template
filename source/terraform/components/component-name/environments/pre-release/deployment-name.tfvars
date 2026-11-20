# Values for this deployment in pre-release. The filename is the deployment name
# and part of the state key: lowercase letters, digits and hyphens only.
# Rename it before the first deploy, because renaming later points at fresh
# state. To deploy another target to pre-release, add a .tfvars file here and a
# matching deployments.json entry.

environment  = "pre-release"
project_name = "<project-name>"

# The tags validation in variables.tf requires a non-empty value for each of its keys.
tags = {
  Environment      = "pre-release"
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
