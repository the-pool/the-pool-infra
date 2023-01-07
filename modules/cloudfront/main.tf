locals {
  api_gateway_origin_id = "thepool_apigw"
  s3_origin_id          = "thepool_s3"
  s3_path               = "/static/*"

  https_redirect_policy = "redirect-to-https"

  all_methods    = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  cached_methods = ["GET", "HEAD"]
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = ""
}

resource "aws_cloudfront_distribution" "thepool_cf_distribution" {
  enabled = true

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
    domain_name = var.s3_domain_name # aws_s3_bucket.the_pool_s3.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    origin_path = local.s3_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  # Certificate Settings
  aliases = var.aliases_domain_name # ["api.thepool.kr"]
  viewer_certificate {
    acm_certificate_arn      = var.acm_arn # aws_acm_certificate.thepool_acm_virginia.arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }

  # 지역 제한
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # 캐시 정책
  default_cache_behavior {
    allowed_methods  = local.all_methods
    cached_methods   = local.cached_methods
    target_origin_id = local.api_gateway_origin_id

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    viewer_protocol_policy = local.https_redirect_policy

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  # 업로드 람다 실행
  ordered_cache_behavior {
    allowed_methods  = local.all_methods
    cached_methods   = local.cached_methods
    target_origin_id = local.s3_origin_id

    path_pattern           = "/static/post/*"
    viewer_protocol_policy = local.https_redirect_policy

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = true
      lambda_arn   = var.upload_lambda_arn
    }
  }

  # 이미지 캐시정책
  ordered_cache_behavior {
    allowed_methods  = local.all_methods
    cached_methods   = local.cached_methods
    target_origin_id = local.s3_origin_id

    path_pattern           = local.s3_path
    viewer_protocol_policy = local.https_redirect_policy

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }
}
