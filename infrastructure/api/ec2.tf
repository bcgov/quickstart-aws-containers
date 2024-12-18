resource "aws_security_group" "jumphost" {
  name        = "${var.app_name}-jumphost-access"
  description = "Allow access to jumphost via ssm"
  vpc_id      = data.aws_vpc.main.id
  ingress {
    protocol = "tcp"
    from_port = 3389
    to_port = 3389
    security_groups = [data.aws_security_group.web.id]
  }

  ingress {
    protocol = "tcp"
    from_port = 3389
    to_port = 3389
    security_groups = [data.aws_security_group.app.id]
  }
}
data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "jumphost" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.micro"
  subnet_id = data.aws_subnets.app.ids[0]
  vpc_security_group_ids = [data.aws_security_group.app.id, aws_security_group.jumphost.id]
  ebs_optimized = false
  ebs_block_device {
    device_name = "${var.app_env}/dev/xvda"
    encrypted = true
    volume_size = 8
  }

  tags = {
    Name = "jumphost-${var.app_env}"
  }
}