data "aws_ami" "debian_12" {
  most_recent = true
  owners      = ["136693071363"] # Debian
  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# debian doesnt ship with ssm agent so we install it using user data
locals {
  debian_ssm_user_data = <<-EOF
#!/bin/bash
set -euxo pipefail

# Log everything from this script
exec > /var/log/user-data-ssm.log 2>&1

echo "[INFO] Starting SSM bootstrap on Debian 12..."

# Basic updates
apt-get update -y
apt-get install -y curl

echo "[INFO] Downloading SSM Agent .deb..."
curl -fSL -o /tmp/amazon-ssm-agent.deb \
  https://s3.ca-central-1.amazonaws.com/amazon-ssm-ca-central-1/latest/debian_amd64/amazon-ssm-agent.deb

echo "[INFO] Installing SSM Agent..."
dpkg -i /tmp/amazon-ssm-agent.deb

echo "[INFO] Enabling + starting SSM Agent..."
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

echo "[INFO] Finished SSM bootstrap."
EOF
}



resource "aws_instance" "server" {
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.nodes.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }

  user_data = local.debian_ssm_user_data

  tags = {
    Name = "server"
    Role = "kubernetes-control-plane"
  }
}


resource "aws_instance" "node_0" {
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.nodes.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }

  user_data = local.debian_ssm_user_data

  tags = {
    Name = "node-0"
    Role = "kubernetes-worker"
  }
}

resource "aws_instance" "node_1" {
  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.nodes.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }

  user_data = local.debian_ssm_user_data

  tags = {
    Name = "node-1"
    Role = "Kubernetes-worker"
  }
}
