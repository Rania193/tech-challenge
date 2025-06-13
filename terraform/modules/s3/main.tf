# S3 bucket for challenge storage
resource "aws_s3_bucket" "challenge_bucket" {
  bucket = "${var.project_name}-bucket-${var.environment}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-bucket"
    Environment = var.environment
  }
}