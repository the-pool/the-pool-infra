variable "name" {
  type = string
}

variable "tags" {

}

variable "public_subnet_ids" {
  type = list(string)
}

# variable "private_subnets_ids" {
#   type = list(string)
# }

variable "security_group_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}
