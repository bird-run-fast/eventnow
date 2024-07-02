variable "env_name" {
  type = string
  default = dev
}

variable "resource_name_prefix" {
  type = string
  default = null
}

variable "zones" {
  description = "zones object"
  type        = map(any)
}

variable "private_zone_name" {
  description = "zone string"
  type        = string
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
}

variable "subnet_ids" {
  type = set(string)
  default = null
}

variable "create_route53_resolver" {
  type = bool
  default = true
}
