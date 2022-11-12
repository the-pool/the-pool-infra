resource "aws_s3_bucket" "the_pool_s3" {
  bucket = "the-pool-s3-1112"
}

output "s3_url" {
  value = aws_s3_bucket.the_pool_s3.bucket_domain_name
}
