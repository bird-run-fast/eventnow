resource "aws_subnet" "app" {
  for_each = { for k, v in var.app_subnets : k => v }
  vpc_id   = aws_vpc.main.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = each.value.tags
}

resource "aws_subnet" "rds" {
  for_each = { for k, v in var.rds_subnets : k => v }
  vpc_id   = aws_vpc.main.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = each.value.tags
}

resource "aws_subnet" "elb" {
  for_each = { for k, v in var.elb_subnets : k => v }
  vpc_id   = aws_vpc.main.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = each.value.tags
}

resource "aws_subnet" "natgw" {
  for_each = { for k, v in var.natgw_subnets : k => v }
  vpc_id   = aws_vpc.main.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = each.value.tags
}
