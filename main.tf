provider "aws" {
	region = "us-east-2"
}

#Rampup resources already created

resource "aws_vpc" "vpc-training" {
	cidr_block       = "10.0.0.0/16"
	
	tags = {
		responsible = var.responsible
		project = var.project
	}
}


resource "aws_subnet" "subnet-public-training" {
	count = "${length(var.subnet_cidrs_public)}"

	vpc_id = "${aws_vpc.vpc-training.id}"
	cidr_block = "${var.subnet_cidrs_public[count.index]}"
	availability_zone = "${var.availability_zones[count.index]}"

	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_subnet" "subnet-private-training" {
	count = "${length(var.subnet_cidrs_private)}"

	vpc_id = "${aws_vpc.vpc-training.id}"
	cidr_block = "${var.subnet_cidrs_private[count.index]}"
	availability_zone = "${var.availability_zones[count.index]}"

	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_internet_gateway" "igw-training" {
	vpc_id = "${aws_vpc.vpc-training.id}"
	
	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_nat_gateway" "natgw-training" {
  allocation_id = "eipalloc-09c2fa75915c0a97f"
  subnet_id     = "${lookup(element(aws_subnet.subnet-public-training, 0),"id", "")}"

  tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_route_table" "rt-public-training" {
	vpc_id = "${aws_vpc.vpc-training.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.igw-training.id}"
	}

	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_main_route_table_association" "rt-main-public-training" {
  vpc_id         = "${aws_vpc.vpc-training.id}"
  route_table_id = "${aws_route_table.rt-public-training.id}"

  tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_route_table_association" "rt-public-training" {
	count = "${length(var.subnet_cidrs_public)}"
	
	subnet_id      = "${element(aws_subnet.subnet-public-training.*.id, count.index)}"
	route_table_id = "${aws_route_table.rt-public-training.id}"

	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_route_table" "rt-private-training" {
	vpc_id = "${aws_vpc.vpc-training.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${aws_nat_gateway.natgw-training.id}"
	}

	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_route_table_association" "rt-private-training" {
	count = "${length(var.subnet_cidrs_private)}"
	
	subnet_id      = "${element(aws_subnet.subnet-private-training.*.id, count.index)}"
	route_table_id = "${aws_route_table.rt-private-training.id}"

	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_network_acl" "acl-public-training" {
	count = "${length(var.subnet_cidrs_public)}"
	
	vpc_id = "${aws_vpc.vpc-training.id}"
	subnet_id = "${element(aws_subnet.subnet-public-training.*.id, count.index)}"

	ingress {
		protocol   = "tcp"
		rule_no    = 100
		action     = "allow"
		cidr_block = "181.129.163.202/32"
		from_port  = 22
		to_port    = 22
	}

	ingress {
		protocol   = "tcp"
		rule_no    = 120
		action     = "allow"
		cidr_block = "0.0.0.0/0"
		from_port  = 80
		to_port    = 80
	}

	ingress {
		protocol   = "tcp"
		rule_no    = 140
		action     = "allow"
		cidr_block = "0.0.0.0/0"
		from_port  = 443
		to_port    = 443
	}

	ingress {
		protocol   = "tcp"
		rule_no    = 140
		action     = "allow"
		cidr_block = "0.0.0.0/0"
		from_port  = 443
		to_port    = 443
	}

	ingress = {
		protocol = "tcp"
		rule_no = 160
		action = "allow"
		cidr_block =  "0.0.0.0/0"
		from_port = 1024
		to_port = 65535
	}

	ingress = {
		protocol = "all"
		rule_no = 180
		action = "allow"
		cidr_block =  "${aws_vpc.vpc-training.cidr_block}"
		from_port = 0
		to_port = 65535
	}

	ingress = {
		protocol = "tcp"
		rule_no = 200
		action = "allow"
		cidr_block =  "0.0.0.0/0"
		from_port = 3030
		to_port = 3030
	}

	ingress = {
		protocol = "all"
		rule_no = 220
		action = "deny"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 65535
	}


	egress {
		protocol   = "all"
		rule_no    = 100
		action     = "allow"
		cidr_block = "0.0.0.0/0"
		from_port  = 0
		to_port    = 65535
	}

	egress = {
		protocol = "all"
		rule_no = 120
		action = "deny"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 65535
	}

	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_network_acl" "acl-private-training" {
	count = "${length(var.subnet_cidrs_private)}"
	
	vpc_id = "${aws_vpc.vpc-training.id}"
	subnet_id = "${element(aws_subnet.subnet-private-training.*.id, count.index)}"

	ingress {
		protocol   = "tcp"
		rule_no    = 100
		action     = "allow"
		cidr_block = "181.129.163.202/32"
		from_port  = 22
		to_port    = 22
	}

	ingress {
		protocol   = "tcp"
		rule_no    = 120
		action     = "allow"
		cidr_block = "10.0.0.0/16"
		from_port  = 22
		to_port    = 22
	}

	ingress {
		protocol   = "tcp"
		rule_no    = 140
		action     = "allow"
		cidr_block = "0.0.0.0/0"
		from_port  = 1024
		to_port    = 65535
	}

	ingress = {
		protocol = "all"
		rule_no = 160
		action = "deny"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 65535
	}

	egress {
		protocol   = "tcp"
		rule_no    = 100
		action     = "allow"
		cidr_block = "0.0.0.0/0"
		from_port  = 80
		to_port    = 80
	}

	egress {
		protocol   = "tcp"
		rule_no    = 120
		action     = "allow"
		cidr_block = "0.0.0.0/0"
		from_port  = 443
		to_port    = 443
	}

	egress {
		protocol   = "tcp"
		rule_no    = 140
		action     = "allow"
		cidr_block = "10.0.0.0/16"
		from_port  = 1024
		to_port    = 65535
	}

	egress = {
		protocol = "all"
		rule_no = 160
		action = "allow"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 65535
	}

	egress = {
		protocol = "all"
		rule_no = 180
		action = "deny"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 65535
	}

	tags = {
		responsible = var.responsible
		project = var.project
	}
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = # add a CIDR block here
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = ["pl-12c4e678"]
  }
}