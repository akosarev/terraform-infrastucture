
output "id" {
  value = aws_vpc.main.id
}

output "private_subnets_web" {
  value = aws_subnet.private_subnets_web.*.id
}
output "public_subnets_web" {
  value = aws_subnet.public_subnets_web.*.id
}

output "ip" {
  value = aws_nat_gateway.infra-nat-gateway.*.public_ip
}