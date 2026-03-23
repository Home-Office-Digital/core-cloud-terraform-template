# Add providers and versions here
terraform {
  required_version = ">= 1.9.3"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.88.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}