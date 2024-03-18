####################
# The packer role which can be assumed by the packer user or an EC2 instance
#
# A role needs to be allowed to assume in both directions. The role needs to
# specify which entities can assume it, and the entities need to specify which
# roles they can assume.
####################

# This trusted entities policy document specifies which user, or specific EC2 instances, can assume the packer role below.

data "aws_iam_policy_document" "packer_trusted_entities_policy_document" {
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
        "repo:fe-ax/packer-blog:*",
        "repo:fe-ax/ami:*",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# Create the role for packer and connect the trusted entities policy document to the role.

resource "aws_iam_role" "packer_role" {
  name               = "packer_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.packer_trusted_entities_policy_document.json
}


####################
# The policy for the packer role from the packer documentation https://developer.hashicorp.com/packer/plugins/builders/amazon#iam-task-or-instance-role
#
# These are the permissions needed to create an AMI. These permissions are given to the packer role, which can be assumed by the packer user, or an EC2 instance.
####################

# The policy document to be attached to the packker_role_policy below

data "aws_iam_policy_document" "packer_role_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances"
    ]
    resources = ["*"]
  }
}

# Connect the policy document to the policy

resource "aws_iam_policy" "packer_role_policy" {
  name        = "packer_role_policy"
  path        = "/"
  description = "The role for packer to create the AMI"
  policy      = data.aws_iam_policy_document.packer_role_policy_document.json
}

# Attach the permissions policy to the role created above. This is what allows the role to create the AMI.

resource "aws_iam_role_policy_attachment" "packer_role_policy_attachment" {
  role       = aws_iam_role.packer_role.name
  policy_arn = aws_iam_policy.packer_role_policy.arn
}

####################
# The policy used by aws_iam_policy.assume_packer_role_policy to assume the packer role
#
# This policy allows the packer user to TRY to assume the packer role. You have to add the packer user to the trusted entities policy document to allow the user to assume the role.
####################

# The policy document to be attached to the assume_packer_role_policy below

data "aws_iam_policy_document" "assume_packer_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.packer_role.arn]
  }
}

# Connect the policy document above to the policy

resource "aws_iam_policy" "assume_packer_role_policy" {
  name        = "assume_packer_role_policy"
  path        = "/"
  description = "The policy to assume the role for Packer"
  policy      = data.aws_iam_policy_document.assume_packer_role_policy_document.json
}
