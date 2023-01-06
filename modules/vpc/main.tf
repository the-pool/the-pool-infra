# ========================
# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr # "10.0.0.0/16"
  tags = merge(
    {
      Name = format("%s-vpc", var.name)
    },
    var.tags
  )
}


# ========================
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      Name = format("%s-igw", var.name)
    },
    var.tags
  )
}


# ========================
# Public Subnet
resource "aws_subnet" "public" {
  for_each          = var.public_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["zone"]

  tags = merge(
    {
      Name = format(
        "%s-public-subnet-%s",
        var.name,
        each.key
      )
    },
    var.tags
  )
}


# ========================
# Private Subnet
# resource "aws_subnet" "private" {
#   for_each          = var.private_subnets
#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = each.value["cidr"]
#   availability_zone = each.value["zone"]
# }


# ========================
# Public route table & associate
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = format(
        "%s-public-route-table",
        var.name,
      )
    },
    var.tags,
  )
}

resource "aws_route_table_association" "public" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}


# ========================
# Private route table & associate
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gateway.id
#   }
# }

# resource "aws_route_table_association" "private" {
#   for_each       = var.private_subnets
#   subnet_id      = aws_subnet.private[each.key].id
#   route_table_id = aws_route_table.private.id
# }
