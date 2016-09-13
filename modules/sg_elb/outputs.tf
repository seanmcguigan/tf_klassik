// Output ID of elb SG 

output "security_group_id" {
  value = "${aws_security_group.elb_security_group.id}"
}
