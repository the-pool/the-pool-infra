resource "aws_cloudfront_origin_access_identity" "thepool_cf_oai" {
  comment = ""
}

resource "aws_cloudfront_distribution" "thepool_cf_distribution" {
  origin {
    domain_name = replace(aws_apigatewayv2_stage.thepool_api_gateway_stage.invoke_url, "/^https?://([^/]*).*/", "$1")
    origin_id   = "thepool_apigw"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.the_pool_s3.bucket_regional_domain_name
    origin_id   = "thepool_s3"
    origin_path = "/static/*"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.thepool_cf_oai.cloudfront_access_identity_path
    }
  }

  enabled = true

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "thepool_apigw"

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "thepool_s3"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }
}
