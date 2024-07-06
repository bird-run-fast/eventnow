# gateway 型
resource "aws_vpc_endpoint" "gateway" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public.id, aws_route_table.private.id]
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  tags = {
    Name = "${var.resource_name_prefix}-s3_vpce"
  }
}

# interface 型
module "vpce-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  use_name_prefix = false

  name   = "vpc-endpoint-sg"
  vpc_id = aws_vpc.main.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = aws_vpc.main.cidr_block
    }
  ]

  egress_rules = ["all-all"]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for sn in aws_subnet.app : sn.id]
  security_group_ids  = [module.vpce-sg.security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.resource_name_prefix}-ecr_dkr_vpce"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for sn in aws_subnet.app : sn.id]
  security_group_ids  = [module.vpce-sg.security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.resource_name_prefix}-ecr_api_vpce"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for sn in aws_subnet.app : sn.id]
  security_group_ids  = [module.vpce-sg.security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.resource_name_prefix}-logs_vpce"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for sn in aws_subnet.app : sn.id]
  security_group_ids  = [module.vpce-sg.security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.resource_name_prefix}-ssm_vpce"
  }
}
