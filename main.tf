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


provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.name
    ]
  }
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


