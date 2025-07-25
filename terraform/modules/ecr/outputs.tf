output "main_api_repository_url" {
  description = "URL of the main-api ECR repository"
  value       = aws_ecr_repository.main_api.repository_url
}

output "auxiliary_service_repository_url" {
  description = "URL of the auxiliary-service ECR repository"
  value       = aws_ecr_repository.auxiliary_service.repository_url
}

output "main_api_repository_arn" {
  description = "Name of the main-api ECR repository"
  value       = aws_ecr_repository.main_api.arn
}

output "auxiliary_service_repository_arn" {
  description = "Name of the auxiliary-service ECR repository"
  value       = aws_ecr_repository.auxiliary_service.arn
}