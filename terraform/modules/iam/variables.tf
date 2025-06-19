variable "project_name" {
  description = "Project name for IAM resources"
  type        = string
}

variable "environment" {
  description = "Environment for IAM resources"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo"
  type        = string
}

variable "repository_arn_list" {
  description = "URLs of the ECR repositories"
  type        = list
  default = []
}
