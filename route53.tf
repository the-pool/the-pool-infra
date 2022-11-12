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
# resource "aws_route53_record" "thepool_api_server_domain" {
#   zone_id = aws_route53_zone.thepool_hosted_zone.id
#   name    = "api.thepool.kr"
#   type    = "A"
#   ttl     = 300
#   records = [aws_eip.api_server_eip.public_ip]
# }
