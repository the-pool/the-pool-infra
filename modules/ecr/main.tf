/*####################################
  - Docker 이미지 저장소로 사용할 ECR 생성
####################################*/
resource "aws_ecr_repository" "api_server_container_repository" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
