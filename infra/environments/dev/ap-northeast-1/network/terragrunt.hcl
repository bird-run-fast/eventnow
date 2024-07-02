# NOTE: common dir を env 直下に切り出して、環境共通リソースとして管理したほうが見やすくなったかも
# 今だと dev で最初に作ったので、dev しか使ってない module にぱっと見みえるので

include "root" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

terraform {
  source = "../../../../modules//network"
}

locals {
  root_vars    = include.root.locals
  aws_region   = local.root_vars.aws_region
  resource_name_prefix = local.root_vars.resource_name_prefix
}

inputs = {
  aws_region = local.aws_region

  resource_name_prefix = local.resource_name_prefix

  allow_connect_norihito_motomura = true

  vpc_cidr_block = "10.0.0.0/20"

  app_subnets = [
    {
      cidr_block        = "10.0.1.0/24",
      availability_zone = "${local.aws_region}a"
      tags = {
        Name = "${local.resource_name_prefix}-APP1"
      }
    },
    {
      cidr_block        = "10.0.2.0/24",
      availability_zone = "${local.aws_region}c"
      tags = {
        Name = "${local.resource_name_prefix}-APP2"
      }
    },
    {
      cidr_block        = "10.0.3.0/24",
      availability_zone = "${local.aws_region}d"
      tags = {
        Name = "${local.resource_name_prefix}-APP3"
      }
    }
  ]

  rds_subnets = [
    {
      cidr_block        = "10.0.4.0/24",
      availability_zone = "${local.aws_region}a"
      tags = {
        Name = "${local.resource_name_prefix}-RDS1"
      }
    },
    {
      cidr_block        = "10.0.5.0/24",
      availability_zone = "${local.aws_region}c"
      tags = {
        Name = "${local.resource_name_prefix}-RDS2"
      }
    },
    {
      cidr_block        = "10.0.6.0/24",
      availability_zone = "${local.aws_region}d"
      tags = {
        Name = "${local.resource_name_prefix}-RDS3"
      }
    }
  ]

  elb_subnets = [
    {
      cidr_block        = "10.0.7.0/24",
      availability_zone = "${local.aws_region}a"
      tags = {
        Name = "${local.resource_name_prefix}-ELB1"
      }
    },
    {
      cidr_block        = "10.0.8.0/24",
      availability_zone = "${local.aws_region}c"
      tags = {
        Name = "${local.resource_name_prefix}-ELB2"
      }
    },
    {
      cidr_block        = "10.0.9.0/24",
      availability_zone = "${local.aws_region}d"
      tags = {
        Name = "${local.resource_name_prefix}-ELB3"
      }
    }
  ]

  natgw_subnets = [{
    cidr_block        = "10.0.14.0/27",
    availability_zone = "${local.aws_region}a"
    tags = {
      Name = "${local.resource_name_prefix}-NAT"
    }
  }]

  transitgw_subnets = [
    {
      cidr_block        = "10.0.14.32/27",
      availability_zone = "${local.aws_region}a"
      tags = {
        Name = "${local.resource_name_prefix}-TRANSITGW1"
      }
    },
    {
      cidr_block        = "10.0.14.64/27",
      availability_zone = "${local.aws_region}c"
      tags = {
        Name = "${local.resource_name_prefix}-TRANSITGW2"
      }
    },
    {
      cidr_block        = "10.0.14.96/27",
      availability_zone = "${local.aws_region}d"
      tags = {
        Name = "${local.resource_name_prefix}-TRANSITGW3"
      }
    }
  ]

}