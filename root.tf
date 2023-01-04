
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


