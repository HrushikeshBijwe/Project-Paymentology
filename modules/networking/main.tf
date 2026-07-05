locals {
  azs = slice(var.availability_zones, 0, var.az_count)
}

# Create the Paymentology VPC
resource "aws_vpc" "paymentology_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

# Create the internet gateway for the VPC
resource "aws_internet_gateway" "paymentology_igw" {
  vpc_id = aws_vpc.paymentology_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.paymentology_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-${count.index + 1}"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.paymentology_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-${count.index + 1}"
      Tier = "private"
    }
  )
}

resource "aws_subnet" "database" {
  count             = var.create_database_subnets ? length(local.azs) : 0
  vpc_id            = aws_vpc.paymentology_vpc.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-database-${count.index + 1}"
      Tier = "database"
    }
  )
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat-eip"
    }
  )
}


# Create NAT gateways for the private subnets
resource "aws_nat_gateway" "paymentology_nat" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.public[0].id
  availability_mode = "regional"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat"
    }
  )

  depends_on = [aws_internet_gateway.paymentology_igw]
}


# Create the public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.paymentology_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.paymentology_igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(local.azs)
  vpc_id = aws_vpc.paymentology_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.paymentology_nat.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-rt-${count.index + 1}"
    }
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "database" {
  count  = var.create_database_subnets ? length(local.azs) : 0
  vpc_id = aws_vpc.paymentology_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-database-rt-${count.index + 1}"
    }
  )
}

resource "aws_route_table_association" "database" {
  count          = var.create_database_subnets ? length(aws_subnet.database) : 0
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}


