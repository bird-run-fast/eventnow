#----------------------------------------
# RDS
#----------------------------------------

# 構成管理が難しいため、RDS クラスター自体は IaC 管理から除外するが、周辺リソースは IaC に残しておく。
# スナップショット復元や B/G でリソース自体を手動で入れ替えたい機会がしばしばあるが
# terraform 運用する場合、各環境で毎度 import しなおす運用負荷などが高いと見積もったため

resource "aws_db_subnet_group" "default" {
  name        = "rds-${var.service_name}-${var.env_short_name}"
  subnet_ids  = var.rds_subnet_ids
}

resource "aws_rds_cluster_parameter_group" "cluster_pg" {
  family      = "aurora-mysql8.0"
  name        = "${var.service_name}-${var.env_short_name}-mysql80"
  parameter {
    apply_method = "immediate"
    name         = "long_query_time"
    value        = "1"
  }
  parameter {
    apply_method = "immediate"
    name         = "slow_query_log"
    value        = "1"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "binlog_format"
    value        = "ROW"
  }
}

#----------------------------------------
# Security Group
#----------------------------------------
module "rds-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  use_name_prefix = false
  name   = "rds-${var.service_name}-${var.env_short_name}"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description = "Allow from APP ECS SG"
      source_security_group_id = var.app_ecs_security_group_id
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description = "Allow from ADMIN ECS SG"
      source_security_group_id = var.admin_ecs_security_group_id
    }
  ]

  egress_rules = ["all-all"]
}

#----------------------------------------
# RDS SSM
#----------------------------------------

resource "aws_ssm_parameter" "db_username" {
  name = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/MASTER_USERNAME"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_password" {
  name = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/MASTER_PASSWORD"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [value]
  }
}