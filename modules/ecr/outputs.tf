output "id" {
  value = aws_ecr_repository.api_server_container_repository.registry_id
}

output "url" {
  value = aws_ecr_repository.api_server_container_repository.repository_url
}

output "arn" {
  value = aws_ecr_repository.api_server_container_repository.arn
}
