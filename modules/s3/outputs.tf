output "domain_name" {
  value = aws_s3_bucket.s3.bucket_regional_domain_name
}