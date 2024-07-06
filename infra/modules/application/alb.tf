#----------------------------------------
# ECS alb Security Group
#----------------------------------------

module "alb-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  use_name_prefix = false

  name   = "alb-${var.service_name}-${var.role}-${var.env_short_name}"
  vpc_id = var.vpc_id

  # NOTE: 
  # cloudfront の prefix list を許可しようとする場合
  # 作業前提として、quota: `Inbound or outbound rules per security group` の上限緩和申請が必要
  ingress_prefix_list_ids = [
    "pl-58a04531" # cloudfront の マネージドプレフィックスリスト
  ] 

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      use_name_prefix = "pl-58a04531" # cloudfront の マネージドプレフィックスリスト
      description = "Allow from cloudfront"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      use_name_prefix = "pl-58a04531" # cloudfront の マネージドプレフィックスリスト
      description = "Allow from cloudfront"
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

#----------------------------------------
# ALB Route53 Record
#----------------------------------------

data "aws_route53_zone" "main" {
  name         = "00615.engineed-exam.com"
  private_zone = false
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.id
  name    = "alb-${var.role}"
  type    = "A"

  alias {
    name                   = resource.aws_lb.app.dns_name
    zone_id                = resource.aws_lb.app.zone_id
    evaluate_target_health = false
  }
}