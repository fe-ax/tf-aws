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

resource "random_id" "tfstate" {
  byte_length = 8
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "tfstate-${random_id.tfstate.hex}"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "app-state-${random_id.tfstate.hex}"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "local_sensitive_file" "foo" {
  content = templatefile("${path.module}/state-backend.tftpl", {
    bucket         = aws_s3_bucket.terraform_state.id
    dynamodb_table = aws_dynamodb_table.terraform_state_lock.name
    region         = var.aws_region
  })
  filename = "${path.module}/../../backend.tf"
}
