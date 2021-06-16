resource "aws_lb_target_group" "tg-api-training" {
  name     = "tg-api-training"
  port     = 3000
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc-training.id

  tags = var.default_tags
}

resource "aws_lb_target_group" "tg-ui-training" {
  name     = "tg-ui-training"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-training.id

  tags = var.default_tags
}

// Autoscaling group
resource "aws_autoscaling_group" "training-ui-as" {
  name                 = "training-ui-as"
  launch_configuration = aws_launch_configuration.training-ui-lc.name
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.subnet-public-training[0].id, aws_subnet.subnet-public-training[1].id]
  target_group_arns    = [aws_lb_target_group.tg-ui-training.arn]

  lifecycle {
    create_before_destroy = true
  }
  tags = var.instance_tags
}

resource "aws_launch_configuration" "training-api-lc" {
  name_prefix     = "training-api-lc"
  image_id        = var.image_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.private-subnets-security-group.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "training-ui-lc" {
  name_prefix     = "training-ui-lc"
  image_id        = var.image_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.public-subnets-security-group.id]

  lifecycle {
    create_before_destroy = true
  }
}

// Autoscaling group
resource "aws_autoscaling_group" "training-api-as" {
  name                 = "training-api-as"
  launch_configuration = aws_launch_configuration.training-api-lc.name
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.subnet-private-training[0].id, aws_subnet.subnet-private-training[1].id]
  target_group_arns    = [aws_lb_target_group.tg-api-training.arn]

  lifecycle {
    create_before_destroy = true
  }

  tags = var.instance_tags
}

//Jenkins server
resource "aws_instance" "jenkins_instance" {

  ami                         = var.image_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.jenkins-server-security-group.id]
  subnet_id                   = aws_subnet.subnet-public-training[0].id
  associate_public_ip_address = true

  tags        = var.jenkins_tags
  volume_tags = var.default_tags
}