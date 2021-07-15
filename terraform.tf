terraform {
  backend "s3" {
    bucket = "state-bucket"
    key    = "infrastructure/terraform.tfstate"
    region = "eu-west-1"
  }
}