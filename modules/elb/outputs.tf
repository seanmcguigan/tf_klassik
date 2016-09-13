output "elb_dns" {
  value = "${aws_elb.klassik.dns_name}"
}