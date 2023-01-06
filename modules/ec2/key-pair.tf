// local 저장
resource "aws_key_pair" "key_pair" {
  key_name   = "the_pool_admin_key_pair"
  public_key = file("~/.ssh/the_pool_admin_key_pair.pub")
}
