// ECR 생성
/*
  - Docker 이미지 저장소로 사용할 ECR 생성
*/
resource "aws_ecr_repository" "api_server_container_repository" {
  name                 = "api_server_container_repository"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

// 출력
/*
  - 이미지 저장소 url 확인
  - 이미지 저장소 id 확인
*/
output "ecr_registry_id" {
  value = aws_ecr_repository.api_server_container_repository.registry_id
}

output "ecr_registry_url" {
  value = aws_ecr_repository.api_server_container_repository.repository_url
}
