output "account_id" {
  description = "Account this deployment ran in."
  value       = data.aws_caller_identity.current.account_id
}

output "name_prefix" {
  description = "Prefix for resource names: <project_name>-<environment>, plus the workspace in ephemeral deploys."
  value       = local.name_prefix
}
