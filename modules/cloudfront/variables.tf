variable "api_gateway_domain_name" {
  type = string
}

variable "s3_domain_name" {
  type = string
}

variable "aliases_domain_name" {
  type = set(string)
}

variable "acm_arn" {
  type = string
}

variable "upload_lambda_arn" {
  type = string
}
