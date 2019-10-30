provider "aws" {
	region = "us-east-2"
}

#Rampup resources already created

resource "aws_vpc" "vpc-training" {
	cidr_block       = "10.0.0.0/16"
	
	tags = var.default_tags
}


resource "aws_subnet" "subnet-public-training" {
	count = "${length(var.subnet_cidrs_public)}"

	vpc_id = "${aws_vpc.vpc-training.id}"
	cidr_block = "${var.subnet_cidrs_public[count.index]}"
	availability_zone = "${var.availability_zones[count.index]}"
	map_public_ip_on_launch = true

	tags = var.default_tags
}

resource "aws_subnet" "subnet-private-training" {
	count = "${length(var.subnet_cidrs_private)}"

	vpc_id = "${aws_vpc.vpc-training.id}"
	cidr_block = "${var.subnet_cidrs_private[count.index]}"
	availability_zone = "${var.availability_zones[count.index]}"

	tags = var.default_tags
}

resource "aws_internet_gateway" "igw-training" {
	vpc_id = "${aws_vpc.vpc-training.id}"
	
	tags = var.default_tags
}

resource "aws_nat_gateway" "natgw-training" {
  allocation_id = "eipalloc-09c2fa75915c0a97f"
  subnet_id     = "${lookup(element(aws_subnet.subnet-public-training, 0),"id", "")}"

  tags = var.default_tags
}

resource "aws_route_table" "rt-public-training" {
	vpc_id = "${aws_vpc.vpc-training.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.igw-training.id}"
	}

	tags = var.default_tags
}

resource "aws_main_route_table_association" "rt-main-public-training" {
  vpc_id         = "${aws_vpc.vpc-training.id}"
  route_table_id = "${aws_route_table.rt-public-training.id}"
}

resource "aws_route_table_association" "rt-public-training" {
	count = "${length(var.subnet_cidrs_public)}"
	
	subnet_id      = "${element(aws_subnet.subnet-public-training.*.id, count.index)}"
	route_table_id = "${aws_route_table.rt-public-training.id}"
}

resource "aws_route_table" "rt-private-training" {
	vpc_id = "${aws_vpc.vpc-training.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${aws_nat_gateway.natgw-training.id}"
	}

	tags = var.default_tags
}

resource "aws_route_table_association" "rt-private-training" {
	count = "${length(var.subnet_cidrs_private)}"
	
	subnet_id      = "${element(aws_subnet.subnet-private-training.*.id, count.index)}"
	route_table_id = "${aws_route_table.rt-private-training.id}"
}

resource "aws_network_acl" "acl-public-training" {
	count = "${length(var.subnet_cidrs_public)}"
	
	vpc_id = "${aws_vpc.vpc-training.id}"
	subnet_ids = ["${element(aws_subnet.subnet-public-training.*.id, count.index)}"]

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

	ingress {
		protocol = "tcp"
		rule_no = 160
		action = "allow"
		cidr_block =  "0.0.0.0/0"
		from_port = 1024
		to_port = 65535
	}

	ingress {
		protocol = "all"
		rule_no = 180
		action = "allow"
		cidr_block =  "${aws_vpc.vpc-training.cidr_block}"
		from_port = 0
		to_port = 0
	}

	ingress {
		protocol = "tcp"
		rule_no = 200
		action = "allow"
		cidr_block =  "0.0.0.0/0"
		from_port = 3030
		to_port = 3030
	}

	ingress {
		protocol = "all"
		rule_no = 220
		action = "deny"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}


	egress {
		protocol   = "all"
		rule_no    = 100
		action     = "allow"
		cidr_block = "0.0.0.0/0"
		from_port  = 0
		to_port    = 0
	}

	egress {
		protocol = "all"
		rule_no = 120
		action = "deny"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}

	tags = var.default_tags
}

resource "aws_network_acl" "acl-private-training" {
	count = "${length(var.subnet_cidrs_private)}"
	
	vpc_id = "${aws_vpc.vpc-training.id}"
	subnet_ids = ["${element(aws_subnet.subnet-private-training.*.id, count.index)}"]

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

	ingress {
		protocol = "all"
		rule_no = 160
		action = "deny"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 0
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

	egress {
		protocol = "all"
		rule_no = 160
		action = "allow"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}

	egress {
		protocol = "all"
		rule_no = 180
		action = "deny"
		cidr_block =  "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}

	tags = var.default_tags
}

resource "aws_security_group" "public-subnets-security-group" {
  name        = "public-subnets-security-group"
  description = "Allow the proper traffic for the front instances"
  vpc_id      = "${aws_vpc.vpc-training.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = 	["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = 	["181.129.163.202/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = 	["10.0.0.0/16"]
  }

  ingress {
    from_port   = 3030
    to_port     = 3030
    protocol    = "tcp"
    cidr_blocks = 	["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = 	["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}

resource "aws_security_group" "private-subnets-security-group" {
  name        = "private-subnets-security-group"
  description = "Allow the proper traffic for the front instances"
  vpc_id      = "${aws_vpc.vpc-training.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = 	["181.129.163.202/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = 	["10.0.0.0/16"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = 	["10.0.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}

resource "aws_security_group" "training-lb-ui-sg" {
  name        = "training-lb-ui-sg"
  description = "Allow all needed ports for internet-facing loadbalancer"
  vpc_id      = "${aws_vpc.vpc-training.id}"
}

// Rules for security group

resource "aws_security_group_rule" "training-lb-sg-rule-ui" {
  security_group_id = "${aws_security_group.training-lb-ui-sg.id}"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "training-lb-sg-rule-ui-outbound" {
  security_group_id = "${aws_security_group.training-lb-ui-sg.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "training-i-lb" {
  name               = "training-i-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = flatten(["${aws_subnet.subnet-private-training.*.id}"])
  
  enable_deletion_protection = false
  
  tags = var.default_tags
}

resource "aws_lb_target_group" "tg-api-training" {
  name     = "tg-api-training"
  port     = 3000
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc-training.id}"

  tags = var.default_tags
}

resource "aws_lb_listener" "training-lb-listener-api" {
  load_balancer_arn = "${aws_lb.training-i-lb.arn}"
  port              = "3000"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg-api-training.arn}"
  }
}


resource "aws_lb" "training-if-lb" {
  name               = "training-if-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.training-lb-ui-sg.id}"]
  subnets            = flatten(["${aws_subnet.subnet-public-training.*.id}"])
  
  enable_deletion_protection = false
  
  tags = var.default_tags
}

resource "aws_lb_target_group" "tg-ui-training" {
  name     = "tg-ui-training"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc-training.id}"

  tags = var.default_tags
}

resource "aws_lb_listener" "training-lb-listener-ui" {
  load_balancer_arn = "${aws_lb.training-if-lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg-ui-training.arn}"
  }
}

resource "aws_launch_configuration" "training-ui-lc" {
  name_prefix          = "training-ui-lc"
  image_id             = "ami-04cce3f889216ffd0"
  instance_type        = "t2.micro"
  security_groups      = ["${aws_security_group.public-subnets-security-group.id}"]
  key_name             = "keypair-training"

  lifecycle {
    create_before_destroy = true
  }
}

// Autoscaling group
resource "aws_autoscaling_group" "training-ui-as" {
  name                 = "training-ui-as"
  launch_configuration = "${aws_launch_configuration.training-ui-lc.name}"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = flatten(["${aws_subnet.subnet-public-training.*.id}"])
  target_group_arns    = ["${aws_lb_target_group.tg-ui-training.arn}"]

  lifecycle {
    create_before_destroy = true
  }
  tags = [
    {
      key                 = "responsible"
      value               = "jibanezn"
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "jibanezn-rampup"
      propagate_at_launch = true
    },
  ]
}

resource "aws_launch_configuration" "training-api-lc" {
  name_prefix          = "training-api-lc"
  image_id             = "ami-04cce3f889216ffd0"
  instance_type        = "t2.micro"
  security_groups      = ["${aws_security_group.private-subnets-security-group.id}"]
  key_name             = "keypair-training"

  lifecycle {
    create_before_destroy = true
  }
}

// Autoscaling group
resource "aws_autoscaling_group" "training-api-as" {
  name                 = "training-api-as"
  launch_configuration = "${aws_launch_configuration.training-api-lc.name}"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = flatten(["${aws_subnet.subnet-private-training.*.id}"])
  target_group_arns    = ["${aws_lb_target_group.tg-api-training.arn}"]

  lifecycle {
    create_before_destroy = true
  }

   tags = [
    {
      key                 = "responsible"
      value               = "jibanezn"
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "jibanezn-rampup"
      propagate_at_launch = true
    },
  ]
}

//Jenkins server
resource "aws_instance" "jenkins_instance" {
	
	ami = "ami-04cce3f889216ffd0"
  	instance_type        = "t2.micro"
	vpc_security_group_ids = ["${aws_security_group.public-subnets-security-group.id}"]
	subnet_id = "${lookup(element(aws_subnet.subnet-public-training, 0),"id", "")}"
	associate_public_ip_address = true

    tags = var.default_tags
}