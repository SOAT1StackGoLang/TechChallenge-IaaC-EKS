provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    region = var.region
  }
}

provider "kubectl" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = module.eks_cluster.cluster_ca_certificate
  token                  = module.eks_cluster.cluster_token
  load_config_file       = false
}