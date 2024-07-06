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
    #TODO: 後で dependency 経由で受け取るようにする
    web_acl_id = "arn:aws:wafv2:us-east-1:992382664063:global/webacl/eventnow-prd/a5b950a8-b46c-4393-a66b-35f2a869f489"
}
