resource "aws_instance" "free_tier_ec2" {
  # Amazon Linux2 ami
  ami           = "ami-0e4a9ad2eb120e054"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  subnet_id = var.public_subnet_ids[0]
  vpc_security_group_ids = [
    var.security_group_id
  ]

  user_data = file("${path.module}/user_data/docker_install.sh")

  iam_instance_profile = var.iam_instance_profile

  tags = merge(
    {
      Name = format(
        "%s-public-ec2",
        var.name
      )
    },
    var.tags,
  )
}
