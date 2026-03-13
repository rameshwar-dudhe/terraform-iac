provider "aws" {
  region = "ap-south-1"
}

#################################
# SECURITY GROUP FOR ALB
#################################

resource "aws_security_group" "alb_sg" {

  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = "vpc-0123456789abcdef0"

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "alb-security-group"

  }

}

#################################
# APPLICATION LOAD BALANCER
#################################

resource "aws_lb" "app_lb" {

  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    "subnet-0123456789abcdef0",
    "subnet-0fedcba9876543210"
  ]

  enable_deletion_protection = false

  idle_timeout = 60

  enable_http2 = true

  ip_address_type = "ipv4"

  drop_invalid_header_fields = true

  enable_cross_zone_load_balancing = true

  access_logs {

    bucket  = "my-alb-log-bucket"
    prefix  = "alb-logs"
    enabled = true

  }

  tags = {

    Name        = "terraform-alb"
    Environment = "dev"

  }

}

#################################
# TARGET GROUP
#################################

resource "aws_lb_target_group" "tg" {

  name     = "terraform-target-group"
  port     = 80
  protocol = "HTTP"

  vpc_id = "vpc-0123456789abcdef0"

  target_type = "instance"

  deregistration_delay = 300

  load_balancing_algorithm_type = "round_robin"

  health_check {

    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"

  }

  stickiness {

    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400

  }

  tags = {

    Name = "terraform-target-group"

  }

}

#################################
# LISTENER HTTP
#################################

resource "aws_lb_listener" "http_listener" {

  load_balancer_arn = aws_lb.app_lb.arn

  port     = 80
  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.tg.arn

  }

}

#################################
# HTTPS LISTENER
#################################

resource "aws_lb_listener" "https_listener" {

  load_balancer_arn = aws_lb.app_lb.arn

  port     = 443
  protocol = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"

  certificate_arn = "arn:aws:acm:ap-south-1:123456789012:certificate/abcd1234"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.tg.arn

  }

}

#################################
# LISTENER RULE
#################################

resource "aws_lb_listener_rule" "example_rule" {

  listener_arn = aws_lb_listener.http_listener.arn

  priority = 100

  action {

    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn

  }

  condition {

    path_pattern {

      values = ["/app*"]

    }

  }

}

#################################
# TARGET ATTACHMENT
#################################

resource "aws_lb_target_group_attachment" "example_target" {

  target_group_arn = aws_lb_target_group.tg.arn

  target_id = "i-0123456789abcdef0"

  port = 80

}
