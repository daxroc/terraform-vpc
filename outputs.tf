output "vpc_id"              { value = "${aws_vpc.default.id}" }
output "region"              { value = "${var.region}" }
output "availability_zones"  { value = ["${var.azs}"] }
output "private_subnet_list" { value = ["${aws_subnet.private.*.id}"] }
output "public_subnet_list"  { value = ["${aws_subnet.public.*.id}"] }