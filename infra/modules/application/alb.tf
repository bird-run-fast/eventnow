#----------------------------------------
# ECS alb Security Group
#----------------------------------------

module "alb-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  use_name_prefix = false

  name   = "alb-${var.service_name}-${var.role}-${var.env_short_name}"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidr_blocks
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidr_blocks
    }
  ]

  egress_rules = ["all-all"]
}

#----------------------------------------
# ECS alb
#----------------------------------------

resource "aws_lb" "app" {
  name = "${var.service_name}-${var.role}-${var.env_short_name}"
  load_balancer_type = "application"
  subnets = var.public_subnets

  security_groups = [module.alb-sg.security_group_id]
}

#----------------------------------------
# ECS alb Target Group
#----------------------------------------

resource "aws_lb_target_group" "app" {
  name        = "${var.service_name}-${var.role}"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

#----------------------------------------
# ECS alb listener
#----------------------------------------

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    # ALBのリスナーからターゲットグループへforwardする
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_listener" "app2" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
