resource "aws_key_pair" "ssh-ed25519" {
  key_name   = "${local.namespace}-ed25519"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAG523NTKBt+Wd5vp3foDsxzLcT7xnYZVA3WGLIBykO gavin@mac.attlocal.net"
}
