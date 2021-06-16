resource "aws_vpc" "vpc-training" {
  cidr_block = "10.0.0.0/16"

  tags = var.default_tags
}

resource "aws_subnet" "subnet-public-training" {
  count = length(var.subnet_cidrs_public)

  vpc_id                  = aws_vpc.vpc-training.id
  cidr_block              = var.subnet_cidrs_public[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = var.default_tags
}

resource "aws_subnet" "subnet-private-training" {
  count = length(var.subnet_cidrs_private)

  vpc_id            = aws_vpc.vpc-training.id
  cidr_block        = var.subnet_cidrs_private[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = var.default_tags
}

resource "aws_internet_gateway" "igw-training" {
  vpc_id = aws_vpc.vpc-training.id
  tags   = var.default_tags
}

resource "aws_eip" "eip-training" {
  vpc = true
}

resource "aws_nat_gateway" "natgw-training" {
  allocation_id = aws_eip.eip-training.id
  subnet_id     = aws_subnet.subnet-public-training[0].id
  tags          = var.default_tags
}

resource "aws_route_table" "rt-public-training" {
  vpc_id = aws_vpc.vpc-training.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-training.id
  }

  tags = var.default_tags
}

resource "aws_main_route_table_association" "rt-main-public-training" {
  vpc_id         = aws_vpc.vpc-training.id
  route_table_id = aws_route_table.rt-public-training.id
}

resource "aws_route_table_association" "rt-public-training" {
  count = length(var.subnet_cidrs_public)

  subnet_id      = aws_subnet.subnet-public-training[count.index].id
  route_table_id = aws_route_table.rt-public-training.id
}

resource "aws_route_table" "rt-private-training" {
  vpc_id = aws_vpc.vpc-training.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw-training.id
  }

  tags = var.default_tags
}

resource "aws_route_table_association" "rt-private-training" {
  count = length(var.subnet_cidrs_private)

  subnet_id      = aws_subnet.subnet-private-training[count.index].id
  route_table_id = aws_route_table.rt-private-training.id
}

resource "aws_network_acl" "acl-public-training" {
  vpc_id     = aws_vpc.vpc-training.id
  subnet_ids = [aws_subnet.subnet-public-training[0].id, aws_subnet.subnet-public-training[1].id]

  dynamic "ingress" {
    for_each = var.nacl_public_ports
    iterator = port
    content {
      from_port  = port.value
      to_port    = port.value
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
      rule_no    = port.key * 100 + 10
      action     = "allow"
    }
  }

  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = var.default_tags
}

resource "aws_network_acl" "acl-private-training" {
  vpc_id     = aws_vpc.vpc-training.id
  subnet_ids = [aws_subnet.subnet-private-training[0].id, aws_subnet.subnet-private-training[1].id]

  dynamic "ingress" {
    for_each = var.nacl_public_ports
    iterator = port
    content {
      from_port  = port.value
      to_port    = port.value
      protocol   = "tcp"
      cidr_block = aws_vpc.vpc-training.cidr_block
      rule_no    = port.key * 100 + 10
      action     = "allow"
    }
  }

  dynamic "egress" {
    for_each = var.nacl_private_ports
    iterator = port
    content {
      from_port  = port.value
      to_port    = port.value
      protocol   = "tcp"
      cidr_block = aws_vpc.vpc-training.cidr_block
      rule_no    = port.key * 100 + 10
      action     = "allow"
    }
  }

  tags = var.default_tags
}