variable "vpc_cidr_block" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "resource_name_prefix" {
  type = string
}

variable "app_subnets" {
  type = list(object({
    cidr_block        = string,
    availability_zone = string,
    tags              = map(string)
  }))
  default = []
}

variable "rds_subnets" {
  type = list(object({
    cidr_block        = string,
    availability_zone = string,
    tags              = map(string)
  }))
  default = []
}

variable "elb_subnets" {
  type = list(object({
    cidr_block        = string,
    availability_zone = string,
    tags              = map(string)
  }))
  default = []
}

variable "natgw_subnets" {
  type = list(object({
    cidr_block        = string,
    availability_zone = string,
    tags              = map(string)
  }))
  default = []
}

variable "transitgw_subnets" {
  type = list(object({
    cidr_block        = string,
    availability_zone = string,
    tags              = map(string)
  }))
  default = []
}
