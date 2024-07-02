resource "aws_vpc_endpoint" "gateway" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public.id, aws_route_table.private.id]
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  tags = {
    Name = "${var.resource_name_prefix}-s3_vpce"
  }
}