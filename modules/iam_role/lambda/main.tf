# ========================
# IAM Role
resource "aws_iam_role" "lambda_role" {
  name               = "thepool_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }

    effect = "Allow"
  }
}


# ========================
# IAM Policy
resource "aws_iam_policy" "lambda_policy" {
  name        = "thepool_lambda_policy"
  path        = "/"
  description = "Policy to provide permisson to lambda"
  policy      = data.aws_iam_policy_document.lambda_policy_data.json
}

data "aws_iam_policy_document" "lambda_policy_data" {
  statement {
    sid = "AllowS3FullAccess"

    actions = [
      "s3:*",
    ]

    effect = "Allow"

    resources = ["${var.s3_arn}/*"]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    effect = "Allow"

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "iam:CreateServiceLinkedRole",
      "lambda:GetFunction",
      "lambda:EnableReplication",
      "cloudfront:UpdateDistribution",
    ]
    effect = "Allow"

    resources = ["*"]
  }
}


# ========================
# IAM Role attach Policy
resource "aws_iam_policy_attachment" "lambda_policy_role" {
  name       = "lambda_attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}
