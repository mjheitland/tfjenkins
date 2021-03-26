#--- compute/outputs.tf
output "keypair_id" {
  value = join(", ", aws_key_pair.tfmh_keypair.*.id)
}
output "server_ids" {
  value = join(", ", aws_instance.tfmh_server.*.id)
}
output "server_public_ips" {
  value = join(", ", aws_instance.tfmh_server.*.public_ip)
}
output "alb_dns" {
  value = aws_lb.tfmh_lb.dns_name
}
