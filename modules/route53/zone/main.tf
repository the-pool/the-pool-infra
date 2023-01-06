resource "aws_route53_zone" "hosted_zone" {
  name    = var.name # "thepool.kr"
  comment = var.comment
}
