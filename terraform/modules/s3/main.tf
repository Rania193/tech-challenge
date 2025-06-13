# S3 bucket for challenge storage
resource "aws_s3_bucket" "challenge_bucket" {
  bucket = "${var.project_name}-bucket-${var.environment}"


  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = var.environment
  }
}
resource "aws_s3_bucket_versioning" "challenge_bucket_versioning" {
  bucket = aws_s3_bucket.challenge_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "challenge_bucket_encryption" {
  bucket = aws_s3_bucket.challenge_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "challenge_bucket_access" {
  bucket                  = aws_s3_bucket.challenge_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}