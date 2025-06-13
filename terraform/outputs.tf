output "challenge_bucket_name" {
  description = "Name of the challenge S3 bucket"
  value       = module.s3.challenge_bucket_name
}


output "parameter_names" {
  description = "List of created parameter names"
  value       = module.ssm.parameter_names
}

output "access_key_id" {
  description = "Access key ID for the IAM user"
  value       = module.iam.access_key_id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key for the IAM user"
  value       = module.iam.secret_access_key
  sensitive   = true
}