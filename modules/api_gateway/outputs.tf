output "endpoint" {
  value = aws_apigatewayv2_api.api_gateway.api_endpoint
}

output "url" {
  value = aws_apigatewayv2_stage.api_gateway_stage.invoke_url
}
