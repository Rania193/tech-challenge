module "s3" {
  source      = "./modules/s3"
  project_name = var.project_name
  environment  = var.environment
}

module "ssm" {
  source      = "./modules/ssm"
  project_name = var.project_name
  environment  = var.environment
  parameters  = {
    "param1" = "example-value-1"
    "param2" = "example-value-2"
  }
}

module "iam" {
  source      = "./modules/iam"
  project_name = var.project_name
  environment  = var.environment
  github_repo  = var.github_repo
}