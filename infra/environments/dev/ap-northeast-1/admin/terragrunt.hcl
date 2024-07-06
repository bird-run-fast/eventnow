terraform {
  source = "../../../../modules//application"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "network" {
  config_path = "../../../common/ap-northeast-1/network"
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
  role                      = "admin"

  vpc_id              = dependency.network.outputs.vpc.id
  public_subnets      = [for v in dependency.network.outputs.elb_subnets : v.id]
  private_subnets     = [for v in dependency.network.outputs.app_subnets : v.id]
  acm_certificate_arn = dependency.acm.outputs.aws_acm_certificate.arn
  ingress_cidr_blocks = "0.0.0.0/0"
  create_auto_scaling = false
  # app の SG に admin からの通信を許可する
  api_security_group_id = "sg-0f91e13a291181e56"
}
