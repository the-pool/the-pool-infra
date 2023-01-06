variable "domain_name" {
  description = "domain name"
  type        = string
}

variable "validation_method" {
  description = "authentication method"
  default     = "DNS"
  type        = string
}
