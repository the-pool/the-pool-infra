output "public_ip" {
  value = aws_eip.eip.public_ip
}

output "ec2_id" {
  value = aws_instance.free_tier_ec2.id
}
