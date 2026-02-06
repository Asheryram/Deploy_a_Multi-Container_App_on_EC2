# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    repo_url         = var.repo_url
    auto_start       = var.auto_start
    db_root_password = var.db_root_password
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    frontend_port    = var.frontend_port
    backend_port     = var.backend_port
  })

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-server"
  })
}
