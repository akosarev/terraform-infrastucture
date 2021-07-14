terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.35.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-1"
}


module "network" {
  source = "./network"
}

module "eks" {
  source              = "./eks"
  private_subnets_web = module.network.private_subnets_web
  public_subnets_web  = module.network.public_subnets_web
  ip                  = module.network.ip
}


