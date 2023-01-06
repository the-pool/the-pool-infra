vpc_cidr = "10.60.0.0/16"

az_names = [
  "ap-northeast-2a",
]

public_subnets = {
  a = {
    zone = "ap-northeast-2a"
    cidr = "10.0.0.0/24"
  }
}

private_subnets = {
}
