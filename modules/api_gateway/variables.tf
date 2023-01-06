
variable "name" {
  type = string
}

variable "stage" {
  default = "$default"
  type    = string
}

variable "protocol_type" {
  type = string
}

variable "integration_ip" {
  type = string
}

variable "integration_type" {
  type = string
}

variable "integration_method" {
  type = string
}

variable "route_key" {
  type = string
}

