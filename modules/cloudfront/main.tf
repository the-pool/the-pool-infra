locals {
  api_gateway_origin_id = "thepool_apigw"
  s3_origin_id          = "thepool_s3"
  s3_path               = "/uploads"

  https_redirect_policy = "redirect-to-https"

  all_methods    = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  cached_methods = ["GET", "HEAD", "OPTIONS"]
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = ""
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "thepool oac"
  description                       = "thepool oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "thepool_cf_distribution" {
  enabled             = true
  default_root_object = "index.html"


  origin {
    domain_name = var.api_gateway_domain_name
    origin_id   = local.api_gateway_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name              = var.s3_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

    custom_header {
      name  = "x-env-bucket"
      value = var.s3_bucket_name
    }

    custom_header {
      name  = "x-env-jwt"
      value = var.s3_env_jwt
    }

    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    # }
  }

  # Certificate Settings
  aliases = var.aliases_domain_name
  viewer_certificate {
    acm_certificate_arn      = var.acm_arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }

  # 지역 제한
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # API
  default_cache_behavior {
    allowed_methods  = local.all_methods
    cached_methods   = local.cached_methods
    target_origin_id = local.api_gateway_origin_id

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    viewer_protocol_policy = local.https_redirect_policy
    # cache_policy_id  = data.aws_cloudfront_cache_policy.cache_disabled.id

    forwarded_values {
      query_string = true
      headers      = [
        "Authorization",
        "authorization"
      ]
      cookies {
        forward = "none"
      }
    }
  }

  # 이미지 업로드
  ordered_cache_behavior {
    allowed_methods  = local.all_methods
    cached_methods   = local.cached_methods
    target_origin_id = local.s3_origin_id

    path_pattern           = "${local.s3_path}/post"
    viewer_protocol_policy = local.https_redirect_policy

    min_ttl = 0
    max_ttl = 0
    default_ttl = 0

    forwarded_values {
      query_string = true
      headers      = [
        "Authorization",
        "authorization"
      ]
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = true
      lambda_arn   = var.upload_lambda_arn
    }
  }

  # 이미지 GET
  ordered_cache_behavior {
    allowed_methods  = local.all_methods
    cached_methods   = local.cached_methods
    target_origin_id = local.s3_origin_id

    path_pattern           = "${local.s3_path}/*"
    viewer_protocol_policy = local.https_redirect_policy

    cache_policy_id = data.aws_cloudfront_cache_policy.cache_policy.id

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 86400
    compress    = true
  }
}

data "aws_cloudfront_cache_policy" "cache_policy" {
  # name = "Managed-CachingOptimized"
  id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

data "aws_cloudfront_cache_policy" "cache_disabled" {
  # CachingDisabled
  id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}