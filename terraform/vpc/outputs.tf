output "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  value       = aws_subnet.public_subnet.*.id
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  value       = aws_subnet.private_subnet.*.id
}

output "vpc_id" {
  description = "ID of VPC"
  value       = aws_vpc.vpc.id
}