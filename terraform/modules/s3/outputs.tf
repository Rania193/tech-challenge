output "challenge_bucket_name" {
  description = "Name of the challenge S3 bucket"
  value       = aws_s3_bucket.challenge_bucket.bucket
}

output "state_bucket_name" {
  description = "Name of the Terraform state S3 bucket"
  value       = aws_s3_bucket.state_bucket.bucket
}