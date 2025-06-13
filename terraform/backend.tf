terraform {
  backend "s3" {
    bucket         = "kantox-terraform-state"
    key            = "challenge/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "kantox-terraform-lock"
  }
}