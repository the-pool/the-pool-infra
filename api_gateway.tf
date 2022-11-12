// API Gateway 생성
/*
  - (HTTP API) api gateway 생성
*/
resource "aws_apigatewayv2_api" "thepool_api_gateway" {
  name          = "thepool-api-gateway"
  description   = "thepool api server proxy"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "thepool_api_gateway_stage" {
  api_id      = aws_apigatewayv2_api.thepool_api_gateway.id
  name        = "$default"
  auto_deploy = true
}

// API Gateway EC2 연결
/*
  - 모든 Method, 모든 라우팅 경로를 프록시 통합으로 target으로 넘기기
  - ec2에 할당된 public ip와 연결
*/
resource "aws_apigatewayv2_route" "thepool_api_gateway_route" {
  api_id    = aws_apigatewayv2_api.thepool_api_gateway.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.thepool_api_gateway_integration.id}"
}

resource "aws_apigatewayv2_integration" "thepool_api_gateway_integration" {
  api_id             = aws_apigatewayv2_api.thepool_api_gateway.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = "http://${aws_eip.api_server_eip.public_ip}:80/{proxy}"
}

// API Gateway에서 사용할 Domain에 TLS 등록
/*
  - API Gateway 내 domain name 생성
  - stage, api와 domain_name 연결
*/
resource "aws_apigatewayv2_domain_name" "thepool_api_gateway_domain_name" {
  domain_name = "api.thepool.kr"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.thepool_subdomain_acm.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "example" {
  api_id      = aws_apigatewayv2_api.thepool_api_gateway.id
  domain_name = aws_apigatewayv2_domain_name.thepool_api_gateway_domain_name.id
  stage       = aws_apigatewayv2_stage.thepool_api_gateway_stage.id
}

// 출력
output "aws_apigateway_endpoint" {
  value = aws_apigatewayv2_api.thepool_api_gateway.api_endpoint
}

output "aws_apigateway_invoke_url" {
  value = aws_apigatewayv2_stage.thepool_api_gateway_stage.invoke_url
}
