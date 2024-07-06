terraform {
  source = "../../../../modules//waf"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  service_name        = include.root.locals.service_name
  environment         = include.root.locals.environment_vars.locals.environment
  env_short_name      = include.root.locals.environment_vars.locals.env_short_name
}
