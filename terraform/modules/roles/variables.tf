variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = null
}

variable "oidc_id_github" {
  description = "Github OIDC ID"
  type        = string
}
