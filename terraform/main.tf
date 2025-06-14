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
  repository_arn_list = [module.ecr.main_api_repository_arn, module.ecr.auxiliary_service_repository_arn]
}

module "ecr" {
  source      = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
}