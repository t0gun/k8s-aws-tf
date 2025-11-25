terraform {
  required_version = ">= 1.13.0, < 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# configure provider
provider "aws" {
  region = var.region
}

