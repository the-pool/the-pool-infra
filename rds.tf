# resource "aws_security_group" "private_subnet_1_sg" {
#   vpc_id      = aws_vpc.the_pool_vpc.id
#   name        = "public-subnet-1-sg"
#   description = "the pool public subnet 1 sg"
#   tags = {
#     Name = "the pool public subnet 1 sg"
#   }
# }
