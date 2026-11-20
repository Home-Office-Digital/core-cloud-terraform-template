output "bucket_id" {
  description = "Name of the example bucket."
  value       = module.s3.bucket_id
  sensitive   = true
}

output "bucket_arn" {
  description = "ARN of the example bucket."
  value       = module.s3.bucket_arn
  sensitive   = true
}

output "kms_key_arn" {
  description = "ARN of the KMS key that encrypts the example bucket."
  value       = module.s3.kms_key_arn
  sensitive   = true
}
