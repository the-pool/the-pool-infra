resource "aws_cloudfront_origin_access_identity" "thepool_cf_oai" {
  comment = ""
}

resource "aws_cloudfront_distribution" "thepool_cf_distribution" {
  origin {
    domain_name = aws_s3_bucket.the_pool_s3.bucket_regional_domain_name
    origin_id   = "thepool_s3"
    origin_path = "static"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.thepool_cf_oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_apigatewayv2_stage.thepool_api_gateway_stage.invoke_url
    origin_id   = "thepool_apigw"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
}
