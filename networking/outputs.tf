#--- networking/outputs.tf ---
output "vpc_id" {
  value = aws_vpc.tfmh_vpc.id
}
output "igw_id" {
  value = aws_internet_gateway.tfmh_igw.id
}
output "subpub_ids" {
  value = aws_subnet.tfmh_subpub.*.id
}
output "subprv_ids" {
  value = aws_subnet.tfmh_subprv.*.id
}
output "sg_id" {
  value = aws_security_group.tfmh_sg.id
}
output "rtpub_ids" {
  value = aws_route_table.tfmh_rtpub.*.id
}
output "rtprv_ids" {
  value = aws_default_route_table.tfmh_rtprv.*.id
}
