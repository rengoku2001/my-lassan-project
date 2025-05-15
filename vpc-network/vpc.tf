# VPC for EKS
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc-name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.ig-name
  }
}

# Public Subnets
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.pub-subnet-name1
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = var.pub-subnet-name2
  }
}

# Private Subnets
resource "aws_subnet" "pvt-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = var.pvt-subnet-name1
  }
}

resource "aws_subnet" "pvt-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = var.pvt-subnet-name2
  }
}

# Elastic IP for NAT
resource "aws_eip" "elasticip" {
  domain = "vpc"
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "natgateway" {
  subnet_id         = aws_subnet.public-subnet1.id
  allocation_id     = aws_eip.elasticip.id
  connectivity_type = "public"

  tags = {
    Name = "eks-nat"
  }
}

# Route Tables - Public
resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = var.public-rt-name
  }
}

resource "aws_route_table_association" "pub-rt-association1" {
  route_table_id = aws_route_table.public-RT.id
  subnet_id      = aws_subnet.public-subnet1.id
}

resource "aws_route_table_association" "pub-rt-association2" {
  route_table_id = aws_route_table.public-RT.id
  subnet_id      = aws_subnet.public-subnet2.id
}

# Route Tables - Private
resource "aws_route_table" "pvt-RT" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgateway.id
  }

  tags = {
    Name = var.pvt-rt-name
  }
}

resource "aws_route_table_association" "pvt-rt-association1" {
  route_table_id = aws_route_table.pvt-RT.id
  subnet_id      = aws_subnet.pvt-subnet1.id
}

resource "aws_route_table_association" "pvt-rt-association2" {
  route_table_id = aws_route_table.pvt-RT.id
  subnet_id      = aws_subnet.pvt-subnet2.id
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "eks-sg" {
  vpc_id      = aws_vpc.vpc.id
  description = "Allowing Jenkins, Sonarqube, SSH Access"

  ingress = [
    for port in [22, 8080, 9000, 9090, 3306, 80] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-sg"
  }
}



