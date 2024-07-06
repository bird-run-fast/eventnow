#----------------------------------------
# ECS Cluster
#----------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${var.service_name}-${var.role}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# #----------------------------------------
# # ECS Task Definition
# #----------------------------------------
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-${var.role}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = module.execution-role.iam_role_arn
  task_role_arn            = module.task-role.iam_role_arn
  cpu                      = 2048
  memory                   = 4096

  container_definitions = jsonencode([
    {
      name  = "web"
      image = "${aws_ecr_repository.web.repository_url}:${aws_ssm_parameter.web-image-tag.value}"
      portMappings = [
        {
          hostPort      = 80
          protocol      = "tcp"
          containerPort = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      // Fargate仕様
      environment = [
        {
          name  = "FCGI_ADDRESS"
          value = "localhost:9000"
        }
      ]
      secrets = []
    },
    {
      name  = "app"
      image = "${aws_ecr_repository.app.repository_url}:${aws_ssm_parameter.app-image-tag.value}"
      portMappings = [
        {
          hostPort      = 9000
          protocol      = "tcp"
          containerPort = 9000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = [
        {
          name  = "APP_ENV",
          value = var.environment
        }
      ]
      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_HOST"
        },
        {
          name      = "DB_PORT"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_PORT"
        },
        {
          name      = "DB_DATABASE"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_DATABASE"
        },
        {
          name      = "DB_USERNAME"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_USERNAME"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/DB_PASSWORD"
        },
        {
          name      = "REDIS_HOST"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/REDIS_HOST"
        },
        {
          name      = "AWS_BUCKET"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/AWS_BUCKET"
        },
        {
          name      = "AWS_URL"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/AWS_URL"
        },
        {
          name      = "ASSETS_ENDPOINT"
          valueFrom = "/${upper(var.service_name)}/${upper(var.environment)}/${upper(var.role)}/ASSETS_ENDPOINT"
        }
      ]
    }
  ])
}

# #----------------------------------------
# # ECS Service
# #----------------------------------------

# ローカルとリモートの task def の revision 比較するための data source 
data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
}

resource "aws_ecs_service" "this" {
  name                   = "${var.service_name}-${var.role}-${var.environment}"
  cluster                = resource.aws_ecs_cluster.main.id
  task_definition        = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  launch_type            = "FARGATE"
  propagate_tags         = "SERVICE"
  enable_execute_command = true
  enable_ecs_managed_tags = true

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [module.ecs-sg.security_group_id]
  }

  // nginx
  load_balancer {
    container_name   = "web"
    container_port   = 80
    target_group_arn = resource.aws_lb_target_group.app.arn
  }
  health_check_grace_period_seconds = 10

  // AutoScalingのためタスク数はTerraformで管理しない
  lifecycle {
    ignore_changes = [
      desired_count,
      enable_execute_command
    ]
  }
}

# #----------------------------------------
# # ECR
# #----------------------------------------
resource "aws_ecr_repository" "web" {
  name = "${var.service_name}-${var.role}-${var.environment}-web"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "app" {
  name = "${var.service_name}-${var.role}-${var.environment}-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}

#----------------------------------------
# Auto Scaling
#----------------------------------------

resource "aws_appautoscaling_target" "this" {
  count              = var.create_auto_scaling ? 1 : 0
  max_capacity       = 50
  min_capacity       = 0
  resource_id        = "service/${resource.aws_ecs_cluster.main.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "target-tracking-scaling" {
  count              = var.create_auto_scaling ? 1 : 0
  name               = "TargetTrackingScaling${title(var.environment)}${title(var.service_name)}${title(var.role)}"
  resource_id        = aws_appautoscaling_target.this.0.resource_id
  scalable_dimension = aws_appautoscaling_target.this.0.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.0.service_namespace

  policy_type = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50
    scale_in_cooldown  = 60
    scale_out_cooldown = 30
  }
}

resource "aws_appautoscaling_policy" "step_scaling" {
  count              = var.create_auto_scaling ? 1 : 0
  name               = "StepScaling${title(var.environment)}${title(var.service_name)}${title(var.role)}"
  resource_id        = aws_appautoscaling_target.this.0.resource_id
  scalable_dimension = aws_appautoscaling_target.this.0.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.0.service_namespace

  policy_type = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 10
      scaling_adjustment          = 5
    }
    step_adjustment {
      metric_interval_lower_bound = 10
      metric_interval_upper_bound = 20
      scaling_adjustment          = 10
    }

    step_adjustment {
      metric_interval_lower_bound = 20
      metric_interval_upper_bound = 30
      scaling_adjustment          = 20
    }

    step_adjustment {
      metric_interval_lower_bound = 30
      scaling_adjustment          = 30
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "step_scaling_alerm" {
  count               = var.create_auto_scaling ? 1 : 0
  alarm_name          = "StepScaling${title(var.environment)}${title(var.service_name)}${title(var.role)}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 60

  dimensions = {
    ClusterName = resource.aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.step_scaling.0.arn]
}

# #----------------------------------------
# # Cloud watch logs
# #----------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.service_name}-${var.role}-${var.environment}"
}

# #----------------------------------------
# # Security Group
# #----------------------------------------
module "ecs-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  use_name_prefix = false

  name   = "ecs-${var.service_name}-${var.role}-${var.environment}"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.alb-sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]
}

# app の SG に admin からの通信を許可するルール
resource "aws_security_group_rule" "allow_from_admin" {
  count = var.role == "admin" ? 1 : 0

  security_group_id        = var.app_security_group_id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.ecs-sg.security_group_id
}

# #----------------------------------------
# # IAM Role
# #----------------------------------------

# ECS タスク実行ロール
module "execution-role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.39.1"

  create_role = true

  role_name         = "${var.service_name}-${var.role}-${var.environment}-ecs-task-execution-role"
  role_requires_mfa = false

  trusted_role_services = ["ecs-tasks.amazonaws.com"]

  custom_role_policy_arns = [module.ecs-task-execution-policy.arn]
}

module "ecs-task-execution-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.39.1"

  name = "${title(var.service_name)}${title(var.role)}${title(var.environment)}ECSTaskExecutionPolicy"

  policy = data.aws_iam_policy_document.ecs-task-execution.json
}

data "aws_iam_policy_document" "ecs-task-execution" {
  statement {
    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]

    effect = "Allow"
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [
      aws_ecr_repository.app.arn,
      aws_ecr_repository.web.arn
    ] 

    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "ssm:GetParameters",
      "ssm:GetParameter",
      "kms:Decrypt"
    ]

    resources = [
      "arn:aws:kms:*:*:key/*",
      "arn:aws:ssm:*"
    ]

    effect = "Allow"
  }
}

# ECS タスクロール
module "task-role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.39.1"

  create_role = true

  role_name         = "${var.service_name}-${var.role}-${var.environment}-ecs-task-role"
  role_requires_mfa = false

  trusted_role_services = ["ecs-tasks.amazonaws.com"]

  custom_role_policy_arns = [module.ecs-task-policy.arn]
}

module "ecs-task-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.39.1"

  name = "${title(var.service_name)}${title(var.role)}${title(var.environment)}ECSTaskPolicy"

  policy = data.aws_iam_policy_document.ecs-task.json
}

data "aws_iam_policy_document" "ecs-task" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "kms:Decrypt",
    ]

    resources = ["*"]

    effect = "Allow"
  }

  statement {
    actions = [
      "ecs:Describe*",
      "ecs:List*"
    ]

    resources = ["*"]

    effect = "Allow"
  }
}
