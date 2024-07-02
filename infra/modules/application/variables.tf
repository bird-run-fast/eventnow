variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "public_subnets" {
  description = "public subnets id"
  type        = list(string)
}

variable "private_subnets" {
  description = "ptivate subnets id"
  type        = list(string)
}

variable "service_name" {
  description = "service name"
  type        = string
}

variable "environment" {
  description = "environment name"
  type        = string
}

variable "env_short_name" {
  description = "env short name"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "allow access alb"
  type        = string
}

variable "app_security_group_id" {
  description = "api security group id"
  type        = string
  default    = "app"
}

variable "role" {
  description = "role name"
  type        = string
}

variable "acm_certificate_arn" {
  description = "alb acm certificate arn"
  type        = string
}

variable "create_auto_scaling" {
  description = "flag create auto scaling"
  type        = string
}
