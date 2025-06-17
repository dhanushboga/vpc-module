# output "az_names" {
#   value = data.aws_availability_zones.available
# }

# output "aws_vpc" {
#   value = data.aws_vpc.default
# }

# output "aws_route_table" {
#     value = data.aws_route_table.main
# }

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database_subnet[*].id
}

output "db_subnet_group" {
  value = aws_db_subnet_group.default[*].id
}