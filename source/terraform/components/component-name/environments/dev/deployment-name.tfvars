# Values for this deployment in dev. The filename is the deployment name and
# part of the state key: lowercase letters, digits and hyphens only. Rename it
# before the first deploy, because renaming later points at fresh state.
# To deploy another target to dev, add a .tfvars file here and a matching
# deployments.json entry.

environment        = "dev"
project_name       = "<project-name>"
notification_email = "<project-mailbox>"

# Required tag keys are set by the CC Tagging Strategy.
tags = {
  Environment      = "dev"
  Project          = ""
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
