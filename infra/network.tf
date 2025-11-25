resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
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
  tags = {
    Name = "k8-aws-tf-private-subnet"
    ManagedBy = "terraform"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "k8-aws-tf-igw"
    ManagedBy = "terraform"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name      = "k8-aws-tf-nat-eip"
    ManagedBy = "terraform"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name      = "k8-aws-tf-nat-gw"
    ManagedBy = "terraform"
  }

  depends_on = [aws_internet_gateway.igw]
}

## Routing

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name      = "k8-aws-tf-public-rt"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name      = "k8-aws-tf-private-rt"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}