// Key pair 생성
/*
  - EC2 원격 접속을 위한 key pair 생성
*/
resource "aws_key_pair" "the_pool_admin_key_pair" {
  key_name   = "the_pool_admin_key_pair"
  public_key = file("~/.ssh/the_pool_admin_key_pair.pub")
}


// Security Group Setting
/*
  - EC2 Security group 생성
  - ssh(22), http(80), https(443) 통신 허용
*/
resource "aws_security_group" "api_server_sg" {
  vpc_id      = aws_vpc.the_pool_vpc.id
  name        = "api server security group"
  description = "api server security group"
  tags = {
    Name = "api server security group"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


// EC2 Setting
/*
  - ec2 생성 & 도커 다운 및 서브넷 설정
  - ip 설정
  - 생성하면서 동시에 도커 설치(https://hossamelshahawi.com/2021/09/30/i/)
*/
resource "aws_instance" "the_pool_api_server" {
  # Amazon Linux2 ami
  ami           = "ami-0e4a9ad2eb120e054"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name      = aws_key_pair.the_pool_admin_key_pair.key_name
  vpc_security_group_ids = [
    aws_security_group.api_server_sg.id
  ]
  user_data = <<-EOF
    #!/bin/bash
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/download/v2.11.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  EOF

  tags = {
    Name = "the pool api server"
  }
}

resource "aws_eip" "api_server_eip" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "api_server_eip_association" {
  instance_id   = aws_instance.the_pool_api_server.id
  allocation_id = aws_eip.api_server_eip.id
}
