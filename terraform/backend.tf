terraform {
  backend "s3" {
    bucket         = "tfstate-feaf737c58ed9d44"
    key            = "states/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "app-state-feaf737c58ed9d44"
    region         = "eu-central-1"
  }
}