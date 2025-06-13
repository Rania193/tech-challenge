output "challenge_bucket_name" {
  description = "Name of the challenge S3 bucket"
  value       = aws_s3_bucket.challenge_bucket.bucket
}