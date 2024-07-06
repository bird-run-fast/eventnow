resource "aws_eip" "main" {
  domain = "vpc" 

  tags = {
    Name = "${var.resource_name_prefix}-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.natgw[0].id
  tags = {
    Name = "${var.resource_name_prefix}-nat"
  }

  depends_on = [aws_eip.main]
}
