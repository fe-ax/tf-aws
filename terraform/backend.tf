terraform {
  backend "s3" {
    bucket         = "tfstate-b79910bcf31c5e9d"
    key            = "states/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "app-state-b79910bcf31c5e9d"
    region         = "eu-central-1"
  }
}