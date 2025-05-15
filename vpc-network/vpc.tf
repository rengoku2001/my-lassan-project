# vpc for eks network

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc-name
  }
}

# internet gateway for eks

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.ig-name
  }
}

# public-subnets

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

# pvt-subnets

resource "aws_subnet" "pvt-subnet1" {
    vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.pvt-subnet-name1
  }
}

resource "aws_subnet" "pvt-subnet2" {
    vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = var.pvt-subnet-name2
  }
}

# NAT gateway for pvt subnets

resource "aws_eip" "elasticip" {
  
}

resource "aws_nat_gateway" "natgateway" {
  subnet_id = aws_subnet.public-subnet1.id
  connectivity_type = "public"
  allocation_id = aws_eip.elasticip.id
   tags = {
    Name = "eks-nat"
  }
}

# PUBLIC route table and associations

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

# PRIVATE route table and associations

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


