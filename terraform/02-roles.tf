module "roles" {
  source         = "./modules/roles"
  oidc_id_github = aws_iam_openid_connect_provider.default.arn
}
