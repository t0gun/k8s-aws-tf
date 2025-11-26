resource "aws_security_group" "nodes" {
  name        = "k8-aws-tf-nodes-sg"
  description = "kthw controller + worker nodes"
  vpc_id      = aws_vpc.main.id

  # full mesh between all nodes using this SG
  ingress {
    # Allow any port
    from_port = 0
    to_port   = 0
    protocol  = "-1" # all protocol
    self      = true # allow traffic from resources using same sg
  }

  ingress {
    protocol = "icmp"
    to_port = -1
    from_port = -1
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    description = "ICMP egress to VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }


  egress { # Outbound HTTP/HTTPS over IPv4 via NAT
    description      = "http egress"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "HTTP egress"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "k8-aws-tf-nodes-sg"
    ManagedBy = "terraform"
    Scope     = "network"
  }
}

