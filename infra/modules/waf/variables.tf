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
