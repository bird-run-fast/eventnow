terraform {
  source = "../../../../modules//rds"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "network" {
  config_path = "../../../common/ap-northeast-1/network"
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
    vpc_id              = dependency.network.outputs.vpc.id
    rds_subnet_ids     = [for v in dependency.network.outputs.rds_subnets : v.id]
    role                      = "rds"

    app_ecs_security_group_id = dependency.app.outputs.ecs_security_group_module.security_group_id
    admin_ecs_security_group_id = dependency.admin.outputs.ecs_security_group_module.security_group_id
}
