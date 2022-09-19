output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
output "subnet_id"{
  value = "${aws_subnet.public_subnet[1].id}"
}
output "private_key" {
  value     = tls_private_key.ec2.private_key_pem
  sensitive = true
}