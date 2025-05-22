resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "dmz" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.dmz_subnet_cidr[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-${count.index}"
  }
}

resource "aws_subnet" "private_ec2" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_ec2_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.environment}-private-${count.index}"
  }
}

resource "aws_subnet" "private_rds" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_rds_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.environment}-private-${count.index}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "main-rt"
  }
}

resource "aws_route_table_association" "dmz" {
  count          = 2
  subnet_id      = aws_subnet.dmz[count.index].id
  route_table_id = aws_route_table.main.id
}
