output "domain_name" {
  value = aws_cloudfront_distribution.thepool_cf_distribution.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.thepool_cf_distribution.hosted_zone_id
}

output "oai_arn" {
  value = aws_cloudfront_origin_access_identity.oai.iam_arn
}

output "distribution_arn" {
  value = aws_cloudfront_distribution.thepool_cf_distribution.arn
}
