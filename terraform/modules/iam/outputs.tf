output "access_key_id" {
  description = "Access key ID for the IAM user"
  value       = aws_iam_access_key.service_key.id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key for the IAM user"
  value       = aws_iam_access_key.service_key.secret
  sensitive   = true
}