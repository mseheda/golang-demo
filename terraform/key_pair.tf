resource "aws_key_pair" "silly_demo_key" {
  key_name   = "silly-demo-key"
  public_key = file("${path.module}/silly-demo-key.pub")
}
