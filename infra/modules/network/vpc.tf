resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.resource_name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.resource_name_prefix}-vpc"
  }
}

resource "aws_subnet" "transitgw" {
  for_each = { for k, v in var.transitgw_subnets : k => v }
  vpc_id   = aws_vpc.main.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = each.value.tags
}