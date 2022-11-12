resource "aws_ecr_repository" "api_server_container_repository" {
  name                 = "api_server_container_repository"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}


output "ecr_registry_id" {
  value = aws_ecr_repository.api_server_container_repository.registry_id
}

output "ecr_registry_url" {
  value = aws_ecr_repository.api_server_container_repository.repository_url
}
