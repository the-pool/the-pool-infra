// S3 셋팅
/*
  - S3 생성
  - 버킷 정책 생성
  - web site 호스팅
*/
resource "aws_s3_bucket" "the_pool_s3" {
  bucket = "the-pool-s3-1112"
}

resource "aws_s3_bucket_policy" "the_pool_s3_policy" {
  bucket = aws_s3_bucket.the_pool_s3.id
  policy = data.aws_iam_policy_document.the_pool_s3_policy_data.json
}

resource "aws_s3_bucket_website_configuration" "the_pool_s3_hosting" {
  bucket = aws_s3_bucket.the_pool_s3.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "the_pool_s3_policy_data" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.the_pool_s3.arn}",
    ]
  }
}

// 출력
output "s3_url" {
  value = aws_s3_bucket.the_pool_s3.bucket_domain_name
}
