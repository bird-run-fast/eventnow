terraform {
  source = "../../../../modules/s3"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  s3_buckets  = [
    {
      service_name   = include.root.locals.service_name
      env_short_name = include.root.locals.environment_vars.locals.env_short_name
      role           = "assets"
      versioning     = "Enabled"
    }
  ]
}
