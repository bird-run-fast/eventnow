locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  aws_region           = try(local.region_vars.locals.aws_region, "ap-northeast-1")
  service_name         = "eventnow"
  resource_name_prefix = "${local.service_name}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOL
provider "aws" {
  region  = "${local.aws_region}"
  default_tags {
    tags = {
      service = "${local.service_name}"
      environment = "${local.environment_vars.locals.environment}"
      terraform = "true"
      aws-exam-resource = "true"
    }
  }
}
provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
EOL
}

remote_state {
  backend = "s3"

  config = {
    encrypt = true
    bucket  = "eventnow-${get_aws_account_id()}"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "ap-northeast-1"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
