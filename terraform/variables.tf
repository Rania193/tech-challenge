variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}
variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "kantox-challenge"
}
variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
variable "github_repo" {
  description = "GitHub repository in the format owner/repo"
  type        = string
  default     = "Rania193/tech-challenge"
}