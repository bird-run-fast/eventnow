variable "service_name" {
  description = "service name"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "env_short_name" {
  description = "short name of environment"
  type        = string
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "redis_subnet_ids" {
  description = "vpc id"
  type        = list(string)
}

variable "role" {
  description = "role name"
  type        = string
}

variable "node_type" {
  description = "node type"
  type        = string
}

variable "app_ecs_security_group_id" {
  description = "vpc id"
  type        = string
}

variable "admin_ecs_security_group_id" {
  description = "vpc id"
  type        = string
}
