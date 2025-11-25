resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  enable_dns_support = true   # for resolving aws service endpoints in SSM

  tags = {
    Name = "k8-aws-tf repo's vpc"
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "k8-aws-tf-public-subnet"
    ManagedBy = "terraform"
  }
}


resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = false

  # carve out a /64 IPv6 block from the VPC IPv6 /56
  ipv6_cidr_block =  cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 0)

  # give each instance an IPv6 on launch
  assign_ipv6_address_on_creation =  true

  tags = {
    Name = "k8-aws-tf-private-subnet"
    ManagedBy = "terraform"
  }
}

resource "aws_egress_only_internet_gateway"  "eigw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "k8-aws-tf-eigw"
    ManagedBy = "terraform"
  }
}


## Routing
resource "aws_route_table" "routing" {
  vpc_id = aws_vpc.main.id
  route {
    ipv6_cidr_block = "::/0"
    egress_only_gateway_id =  aws_egress_only_internet_gateway.eigw.id
  }
}

# Associate subnet with route table so the subnet with  knows its routing with table rules

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.routing.id
}