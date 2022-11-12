// Certificate Setting
/*
  - '*.thepool.kr' 관련 SSL 생성
  - 생성 시 인증방법은 이메잉, DNS 중 DNS
*/
resource "aws_acm_certificate" "thepool_subdomain_acm" {
  domain_name       = "*.thepool.kr"
  validation_method = "DNS"
}
