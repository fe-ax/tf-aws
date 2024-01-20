terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.37.0"
    }
  }
}

# The provider for AWS, using the profile and region from the variables

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

