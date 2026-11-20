terraform {
  required_version = ">= 1.15.0"

  # init from source/terraform/deployments.json. Leave this block empty.
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.88.0"
    }
  }
}

# Credentials come from the workflow's OIDC role. Don't set them here.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}
