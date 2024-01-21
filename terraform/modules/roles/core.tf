resource "aws_iam_user" "core_user" {
  name = "core_user"
  path = "/"
}

resource "aws_iam_group" "core_group" {
  name = "core_group"
  path = "/"
}

resource "aws_iam_group_membership" "core_group_membership" {
  name = "core_group_membership"

  users = [
    "${aws_iam_user.core_user.name}",
  ]

  group = aws_iam_group.core_group.name
}

data "aws_iam_policy_document" "core_trusted_entities_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.core_user.arn]
    }
  }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_id_github]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.allowed_repo}:environment:plan",
        "repo:${local.allowed_repo}:environment:apply"
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

resource "aws_iam_group_policy_attachment" "assume_core_role_policy_attachment" {
  group      = aws_iam_group.core_group.name
  policy_arn = aws_iam_policy.assume_core_role_policy.arn
}

resource "aws_iam_access_key" "core_access_key" {
  user = aws_iam_user.core_user.name
}
