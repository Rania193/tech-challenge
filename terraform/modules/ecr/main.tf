resource "aws_ecr_repository" "main_api" {
  name                 = "main-api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name        = "${var.project_name}-main-api"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "auxiliary_service" {
  name                 = "auxiliary-service"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name        = "${var.project_name}-auxiliary-service"
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "main_api_policy" {
  repository = aws_ecr_repository.main_api.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "auxiliary_service_policy" {
  repository = aws_ecr_repository.auxiliary_service.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}