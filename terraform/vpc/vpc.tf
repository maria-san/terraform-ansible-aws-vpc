# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(tomap({ Name = local.vpc_name }), local.tags)
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(local.vpc_cidr_block, 8, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(tomap({ Name = format("%v-public-%v", local.vpc_name, local.azs[count.index]) }), local.tags)
}

# Routing [Public Subnets]
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(tomap({ Name = local.vpc_name }), local.tags)
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(tomap({ Name = format("%v-public-route-table", local.vpc_name) }), local.tags)
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route" {
  count = length(local.azs)

  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route.id
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(local.vpc_cidr_block, 8, count.index + length(local.azs))
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(tomap({ Name = format("%v-private-%v", local.vpc_name, local.azs[count.index]) }), local.tags)
}

# Routing [Private Subnets]
resource "aws_eip" "nat" {
  count = length(local.azs)

  vpc = true

  tags = merge(tomap({ Name = format("%v-eip-%v", local.vpc_name, local.azs[count.index]) }), local.tags)
}

resource "aws_nat_gateway" "nat" {
  count = length(local.azs)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)

  tags = merge(tomap({ Name = format("%v-nat-%v", local.vpc_name, local.azs[count.index]) }), local.tags)

  depends_on = [aws_eip.nat, aws_internet_gateway.igw, aws_subnet.public_subnet]
}

resource "aws_route_table" "private_route" {
  count = length(local.azs)

  vpc_id = aws_vpc.vpc.id

  tags = merge(tomap({ Name = format("%v-private-route-table-%v", local.vpc_name, local.azs[count.index]) }), local.tags)
}

resource "aws_route" "private_nat_gateway" {
  count = length(local.azs)

  route_table_id         = element(aws_route_table.private_route.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)

  timeouts {
    create = "5m"
  }
}
resource "aws_route_table_association" "private_route" {
  count = length(local.azs)

  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route.*.id, count.index)
}