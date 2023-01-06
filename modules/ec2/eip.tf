resource "aws_eip" "eip" {
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "eip_association" {
  allocation_id = aws_eip.eip.id
  instance_id   = aws_instance.free_tier_ec2.id
}
