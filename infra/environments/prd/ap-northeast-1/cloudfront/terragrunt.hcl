terraform {
  source = "../../../../modules//cloudfront"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "acm" {
  config_path = "../../us-east-1/acm"

  mock_outputs = {
    aws_acm_certificate = {
      arn = "placeholder"
    }
  }
}

dependency "app" {
  config_path = "../application"
}
dependency "admin" {
  config_path = "../admin"
}

inputs = {
    service_name        = include.root.locals.service_name
    environment         = include.root.locals.environment_vars.locals.environment
    env_short_name      = include.root.locals.environment_vars.locals.env_short_name

    resource_name_prefix = "eventnow"
    bucket_name = "00615.engineed-exam.com"
    cloudfront_distribution_aliases = [
      "00615.engineed-exam.com",
      "www.00615.engineed-exam.com",
    ]
    oac_name = "eventnow-oac-assets"
    acm_certificate_arn = dependency.acm.outputs.aws_acm_certificate.arn
    
    app_alb_origin_domain_name = dependency.app.outputs.alb_dns_name
    admin_alb_origin_domain_name = dependency.admin.outputs.alb_dns_name
}
