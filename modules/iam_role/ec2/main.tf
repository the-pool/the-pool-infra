# ========================
# IAM Role
resource "aws_iam_role" "ec2_role" {
  name               = "thepool_ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assuome_role.json
}

data "aws_iam_policy_document" "ec2_assuome_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}


# ========================
# IAM Policy
resource "aws_iam_policy" "ec2_policy" {
  name        = "thepool_ec2_policy"
  path        = "/"
  description = "Policy to provide permisson to EC2"
  policy      = data.aws_iam_policy_document.ec2_policy_data.json
}

data "aws_iam_policy_document" "ec2_policy_data" {
  statement {
    sid = "AllowECRFullAccess"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    effect = "Allow"

    resources = ["arn:aws:ecr:*"] # var.resource_arns
  }

  statement {
    sid = "AllowECRGetAuthorizationToken"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    effect = "Allow"

    resources = ["*"]
  }
}


# ========================
# IAM Role attach Policy
resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}


# ========================
# ec2 profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "thepool_ec2_profile"
  role = aws_iam_role.ec2_role.name
}
