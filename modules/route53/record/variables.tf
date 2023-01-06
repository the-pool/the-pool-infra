variable "domain_name" {
  description = "domain name to use"
  type        = string
}

variable "record_type" {
  description = "record type"
  type        = string
}

variable "hosted_zone_id" {
  description = "route53 hosted zone id"
  type        = string
}

variable "alias_target_name" {
  description = "base target name"
  type        = string
}

variable "alias_target_zone_id" {
  description = "base target zone id"
  type        = string
}
