# vpc endpoints security group so systems manager agent can talk to VPC resources over private network
resource "aws_security_group" "ssm_endpoints" {
  name        = "k8s-aws-tf-ssm-endpoints-sg"
  description = "Allow HTTPS from VPC to aws Systems Manager interface endpoints"
  vpc_id      = aws_vpc.main.id

  # Allow HTTPS from inside the VPC to hit the endpoints
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  # Endpoints will call back into AWS over AWS backbone using AWS ips and ports we dont know
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name      = "k8-aws-tf-ssm-endpoints-sg"
    ManagedBy = "terraform"
    Scope     = "network"
  }

}


# AWS Systems Manager SSM Endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name      = "k8-aws-tf-ssm-endpoint"
    ManagedBy = "terraform"
    Scope     = "network"
  }
}


# EC2Messages endpoint used by AWS systems manager agent
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name      = "k8-aws-tf-ssmmessages-endpoint"
    ManagedBy = "terraform"
    Scope     = "network"
  }
}


# Systems Manager Messaging (SSMMessages) endpoint
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name      = "k8-aws-tf-ssmmessages-endpoint"
    ManagedBy = "terraform"
    Scope     = "network"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name      = "k8-aws-tf-s3-endpoint"
    ManagedBy = "terraform"
  }
}