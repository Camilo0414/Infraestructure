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
  subnet_id     = "${aws_subnet.subnet-public-us-east-2a-training.id}"
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

resource "aws_main_route_table_association" "public" {
  vpc_id         = "${aws_vpc.vpc-training.id}"
  route_table_id = "${aws_route_table.rt-public-training.id}"
}

resource "aws_route_table_association" "public" {
	count = "${length(var.subnet_cidrs_public)}"
	
	subnet_id      = "${element(aws_subnet.subnet-public-us-east-2a-training.*.id, count.index)}"
	route_table_id = "${aws_route_table.rt-public-training.id}"
}

resource "aws_route_table" "rt-private-training" {
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

