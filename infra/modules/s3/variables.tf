variable "s3_buckets" {
  type = list(object({
    service_name   = string
    env_short_name = string
    role           = string
    versioning     = string
  }))
}
