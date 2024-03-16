data "aws_iam_policy_document" "core_trusted_entities_policy_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_id_github]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:fe-ax/tf-aws:*",
        "repo:fe-ax/tf-testingstuff:*",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "core_role" {
  name               = "core_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.core_trusted_entities_policy_document.json
}

data "aws_iam_policy_document" "core_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "core_role_policy" {
  name        = "core_role_policy"
  path        = "/"
  description = "The role for the core to set up roles and policies"
  policy      = data.aws_iam_policy_document.core_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "core_role_policy_attachment" {
  role       = aws_iam_role.core_role.name
  policy_arn = aws_iam_policy.core_role_policy.arn
}

data "aws_iam_policy_document" "assume_core_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.core_role.arn]
  }
}

resource "aws_iam_policy" "assume_core_role_policy" {
  name        = "assume_core_role_policy"
  path        = "/"
  description = "The policy to assume the role for the core"
  policy      = data.aws_iam_policy_document.assume_core_role_policy_document.json
}
