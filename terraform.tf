terraform {
  backend "s3" {
    bucket = "backend-state-terraform-infrastructure"
    key    = "infrastructure/terraform.tfstate"
    region = "eu-west-1"
  }
}