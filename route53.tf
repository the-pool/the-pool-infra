// route53 등록
/*
  - 이미 등록 되어 있는 route53 import해서 사용
  - DNS 서버 렉코드는 이미 등록되어있음(import는 하지 않음)
  - api gateway에 등록한 도메인 이름도 A레코드로 등록
*/
resource "aws_route53_zone" "thepool_hosted_zone" {
  name    = "thepool.kr"
  comment = ""
}

resource "aws_route53_record" "thepool_api_server_domain" {
  name    = aws_apigatewayv2_domain_name.thepool_api_gateway_domain_name.domain_name
  type    = "A"
  zone_id = aws_route53_zone.thepool_hosted_zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.thepool_api_gateway_domain_name.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.thepool_api_gateway_domain_name.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
