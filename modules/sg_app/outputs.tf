// Output ID of app SG 

output "security_group_id" {
  value = "${aws_security_group.app_security_group.id}"
}
