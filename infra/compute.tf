data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"

    values = ["al2023-ami-2023.*-x86_64"]
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



resource "aws_instance" "server" {
  ami =  data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.nodes.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }


  tags = {
    Name = "server"
    Role = "kubernetes-control-plane"
  }
}


resource "aws_instance" "node_0" {
  ami =  data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.nodes.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }


  tags = {
    Name = "node-0"
    Role = "kubernetes-worker"
  }
}

resource "aws_instance" "node_1" {
  ami =  data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.nodes.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }


  tags = {
    Name = "node-1"
    Role = "Kubernetes-worker"
  }
}
