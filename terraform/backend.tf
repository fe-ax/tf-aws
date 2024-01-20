terraform {
  backend "s3" {
    bucket         = "tfstate-ae5c59ff91ad17af"
    key            = "states/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "app-state-ae5c59ff91ad17af"
    region         = "eu-central-1"
  }
}