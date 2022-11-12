// VPC 생성
/*
  - vpc 생성
*/
resource "aws_vpc" "the_pool_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "the-pool-vpc"
  }
}

// Subnet Setting
/*
  - vpc 연결
  - IP address 할당
  - 가용영역 설정
*/
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.the_pool_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "the-pool-public-subnet"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.the_pool_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "the-pool-private-subnet"
  }
}

// IGW Setting
/*
  - vpc 연결
*/
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.the_pool_vpc.id
  tags = {
    Name = "the-pool-igw"
  }
}

// NAT Gateway Setting
/*
  - IP주소 할당 (vpc 내에서 사용)
  - 위치할 서브넷 설정
*/
# resource "aws_eip" "nat_eip" {
#   vpc = true
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_nat_gateway" "nat_gateway" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.public_subnet_1.id
#   tags = {
#     Name = "the-pool-NAT"
#   }
# }

// Route Table Setting
/*
  - public subnet <-> IGW 라우팅 테이블 작성
  - private subnet <-> NAT 라우팅 테이블 작성
*/
resource "aws_route_table" "public_subnet_1_route" {
  vpc_id = aws_vpc.the_pool_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "the-pool-public-subnet-1-route"
  }
}

resource "aws_route_table_association" "route_table_association_public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_1_route.id
}

resource "aws_route_table" "private_subnet_1_route" {
  vpc_id = aws_vpc.the_pool_vpc.id
  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_gateway.id
  # }

  tags = {
    Name = "the-pool-private-subnet-1-route"
  }
}

resource "aws_route_table_association" "route_table_association_private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_subnet_1_route.id
}
