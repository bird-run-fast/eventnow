terraform {
  source = "../../../../../modules//cloudfront"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "acm" {
  config_path = "../acm"

  mock_outputs = {
    aws_acm_certificate = {
      arn = "placeholder"
    }
  }
}

inputs = {
    service_name        = include.root.locals.service_name
    environment         = include.root.locals.environment_vars.locals.environment
    env_short_name      = include.root.locals.environment_vars.locals.env_short_name

    resource_name_prefix = "eventnow"
    bucket_name = "static.dev.00615.engineed-exam.com"
    cloudfront_distribution_aliases = "static.dev.00615.engineed-exam.com"
    oac_name = "eventnow-oac-assets"
    acm_certificate_arn = dependency.acm.outputs.aws_acm_certificate.arn
}
