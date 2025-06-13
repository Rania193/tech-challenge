terraform {
  backend "s3" {
    bucket         = "kantox-challenge-terraform-state"
    key            = "challenge/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "kantox-challenge-terraform-lock"
  }
}