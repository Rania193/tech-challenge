# terraform {
#   backend "s3" {
#     bucket         = "kantox-terraform-state"
#     key            = "challenge/terraform.tfstate"
#     region         = "eu-west-1"
#     use_lockfile   = true # S3 native locking
#   }
# }