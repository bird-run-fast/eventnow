output "vpc" {
  value = aws_vpc.main
}

output "elb_subnets" {
  value = aws_subnet.elb
}

output "app_subnets" {
  value = aws_subnet.app
}

output "rds_subnets" {
  value = aws_subnet.rds
}