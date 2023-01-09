
# ========================
# ACM
locals {
  subdomain_name = "*.thepool.kr"
}

module "acm_northeast_2_subdomain" {
  source      = "./modules/acm"
  domain_name = local.subdomain_name
}

module "acm_virginia_subdomain" {
  source      = "./modules/acm"
  domain_name = local.subdomain_name
  providers = {
    aws = aws.virginia
  }
}


# ========================
# Route53
locals {
  api_server_domain_name = "api.thepool.kr"
}

module "route53_zone" {
  source = "./modules/route53/zone"
  name   = "thepool.kr"
}

module "route53_api_server_record" {
  source = "./modules/route53/record"

  domain_name    = local.api_server_domain_name
  record_type    = "A"
  hosted_zone_id = module.route53_zone.zone_id

  alias_target_name    = module.cloudfront_main.domain_name    # "" #cloudfront 작성 후
  alias_target_zone_id = module.cloudfront_main.hosted_zone_id # "" #cloudfront 작성 후
}


# ========================
# IAM
module "ec2_role" {
  source        = "./modules/iam_role/ec2"
  resource_arns = [module.ecr_main.arn]
}

module "lambda_role" {
  source = "./modules/iam_role/lambda"
  s3_arn = module.s3_main.arn
}


# ========================
# ECR
module "ecr_main" {
  source    = "./modules/ecr"
  repo_name = "api_server_container_repository"
}


# ========================
# VPC - vpc, security group 
locals {
  vpc_cidr = "10.0.0.0/16"
}

module "vpc_main" {
  source   = "./modules/vpc"
  name     = "thepool"
  vpc_cidr = local.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  az_names        = var.az_names

  tags = {}
}

module "ec2_security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc_main.vpc_id
}


# ========================
# EC2
module "ec2_public" {
  source = "./modules/ec2"
  name   = "thepool"
  tags   = {}

  public_subnet_ids = module.vpc_main.public_subnet_ids
  security_group_id = module.ec2_security_group.id

  iam_instance_profile = module.ec2_role.profile_name
}


# ========================
# API Gateway
module "api_gateway_ec2" {
  source = "./modules/api_gateway"
  name   = "thepool"

  stage         = "$default"
  protocol_type = "HTTP"

  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_ip     = module.ec2_public.public_ip

  route_key = "ANY /{proxy+}"
}


# ========================
# S3
module "s3_main" {
  source      = "./modules/s3"
  bucket_name = "the-pool-s3-8520"
}


# ========================
# Cloudfront 
module "cloudfront_main" {
  source = "./modules/cloudfront"
  providers = {
    aws = aws.virginia
  }

  api_gateway_domain_name = replace(module.api_gateway_ec2.url, "/^https?://([^/]*).*/", "$1")
  s3_domain_name          = module.s3_main.domain_name
  s3_bucket_name          = module.s3_main.name
  aliases_domain_name     = [local.api_server_domain_name]

  upload_lambda_arn = module.upload_lambda.arn

  acm_arn = module.acm_virginia_subdomain.arn

  depends_on = [
    module.upload_lambda
  ]
}

# Lambda@Edge
module "upload_lambda" {
  source = "./modules/lambda"
  providers = {
    aws = aws.virginia
  }

  zip_file_name    = "upload_lambda.zip"
  function_name    = "upload_lambda"
  source_file_name = "upload_lambda"
  lambda_role      = module.lambda_role.role_arn
}
