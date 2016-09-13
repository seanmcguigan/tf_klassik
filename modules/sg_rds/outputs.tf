// Output ID of rds SG 

output "security_group_id" {
  value = "${aws_security_group.rds_security_group.id}"
}