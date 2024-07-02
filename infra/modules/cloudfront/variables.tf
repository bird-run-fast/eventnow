variable "service_name" {
  type = string
}

variable "environment" {
  type = string
  default = "develop"
}

variable "env_short_name" {
  type = string
  default = "dev"
}

variable "resource_name_prefix" {
  type = string
  default = null
}

variable "bucket_name" {
  description = "bucket_name"
  type = string
}

variable "cloudfront_distribution_aliases" {
  description = "cloudfront_distribution_aliases"
  type = list(string)
}

variable "oac_name" {
  description = "oac_name"
  type = string
}

variable "acm_certificate_arn" {
  description = "acm_certificate_arn"
  type = string
}

variable "app_alb_origin_domain_name" {
  description = "app_alb_origin_domain_name"
  type = string
}

variable "admin_alb_origin_domain_name" {
  description = "admin_alb_origin_domain_name"
  type = string
}

