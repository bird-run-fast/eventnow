#===========================================
# public subnet
#===========================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.resource_name_prefix}-public_rt"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
  depends_on             = [aws_route_table.public]
}

# attache route table
resource "aws_route_table_association" "elb" {
  for_each = { for k, v in aws_subnet.elb : k => v.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "nat" {
  for_each = { for k, v in aws_subnet.natgw : k => v.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

#===========================================
# private subnet
#===========================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.resource_name_prefix}-private_rt"
  }
}

resource "aws_route" "nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
  depends_on             = [aws_route_table.private]
}

# attache route table
resource "aws_route_table_association" "app" {
  for_each = { for k, v in aws_subnet.app : k => v.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "rds" {
  for_each = { for k, v in aws_subnet.rds : k => v.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "transitgw" {
  for_each = { for k, v in aws_subnet.transitgw : k => v.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}
