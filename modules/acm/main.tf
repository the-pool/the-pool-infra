resource "aws_acm_certificate" "acm" {
  domain_name       = var.domain_name
  validation_method = var.validation_method
}
