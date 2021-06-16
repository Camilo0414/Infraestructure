resource "aws_lb" "training-i-lb" {
  name               = "training-i-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.subnet-private-training.*.id

  enable_deletion_protection = false

  tags = var.default_tags
}



resource "aws_lb_listener" "training-lb-listener-api" {
  load_balancer_arn = aws_lb.training-i-lb.arn
  port              = "3000"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-api-training.arn
  }
}


resource "aws_lb" "training-if-lb" {
  name               = "training-if-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.training-lb-ui-sg.id]
  subnets            = aws_subnet.subnet-public-training.*.id

  enable_deletion_protection = false

  tags = var.default_tags
}



resource "aws_lb_listener" "training-lb-listener-ui" {
  load_balancer_arn = aws_lb.training-if-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-ui-training.arn
  }
}