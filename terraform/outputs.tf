# Add outputs for resources which you need to know details about following creation
# such as KMS key IDs, RDS instance IDs, Endpoint IDs etc....

output "managed_secret_arns" {
  description = "ARNs for secrets created by this stack."
  value = {
    for name, secret in aws_secretsmanager_secret.managed : name => secret.arn
  }
}

output "managed_secret_names" {
  description = "Names for secrets created by this stack."
  value = {
    for name, secret in aws_secretsmanager_secret.managed : name => secret.name
  }
}

output "retrieved_secret_arns" {
  description = "ARNs for existing secrets looked up by this stack."
  value = {
    for name, secret in data.aws_secretsmanager_secret.existing : name => secret.arn
  }
}

output "retrieved_secret_strings" {
  description = "Current secret strings for existing secrets looked up by this stack."
  value       = local.existing_secret_strings
  sensitive   = true
}

output "example_rds_secret_payload" {
  description = "Decoded JSON payload for example_rds_secret_name when that secret stores RDS credentials."
  value       = local.rds_secret_example
  sensitive   = true
}
