#----------------------------------------
# ElastiCache Redis
#----------------------------------------

# データの構成管理との相性が悪いため、Redis クラスター自体は IaC 管理から除外するが、周辺リソースは IaC に残しておく。
# resource "aws_elasticache_replication_group" "main" {
#   replication_group_id = "${var.service_name}-${var.env_short_name}"
#   node_type            = "${var.node_type}"
#   num_cache_clusters   = 1
#   port                 = 6379
#   subnet_group_name    = resource.aws_elasticache_subnet_group.main.name
#   security_group_ids   = [module.redis-sg.security_group_id]
#   parameter_group_name = resource.parameter_group_name
#   engine_version       = "7.1"
# }

resource "aws_elasticache_subnet_group" "main" {
  name       = "redis-${var.service_name}-${var.env_short_name}"
  subnet_ids = var.redis_subnet_ids
}

resource "aws_elasticache_parameter_group" "main" {
  name   = "cache-params-${var.service_name}-${var.env_short_name}"
  family = "redis7"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}

#----------------------------------------
# Security Group
#----------------------------------------
module "redis-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  use_name_prefix = false
  name   = "redis-${var.service_name}-${var.env_short_name}"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      description = "Allow from APP ECS SG"
      source_security_group_id = var.app_ecs_security_group_id
    },
    {
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      description = "Allow from ADMIN ECS SG"
      source_security_group_id = var.admin_ecs_security_group_id
    }
  ]

  egress_rules = ["all-all"]
}
