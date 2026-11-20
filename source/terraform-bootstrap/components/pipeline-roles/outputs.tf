# Put the role names in source/terraform/deployments.json.

output "plan_role_name" {
  description = "Name of the product plan role."
  value       = module.plan_role.name
}

output "plan_role_arn" {
  description = "ARN of the product plan role."
  value       = module.plan_role.arn
}

output "apply_role_name" {
  description = "Name of the product apply role."
  value       = module.apply_role.name
}

output "apply_role_arn" {
  description = "ARN of the product apply role."
  value       = module.apply_role.arn
}
