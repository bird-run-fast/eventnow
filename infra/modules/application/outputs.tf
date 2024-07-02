output "aws_ecr_repository_app_arn" {
  value = resource.aws_ecr_repository.app.arn
}

output "aws_ecr_repository_web_arn" {
  value = resource.aws_ecr_repository.web.arn
}

output "aws_ecs_service_arn" {
  value = resource.aws_ecs_service.this.id
}

output "ecs_execution_role_arn" {
  value = module.execution-role.iam_role_arn
}

output "ecs_task_role_arn" {
  value = module.task-role.iam_role_arn
}

output "ecs_security_group_module" {
  value = module.ecs-sg
}

output "alb_dns_name" {
  value = resource.aws_lb.app.dns_name
}
