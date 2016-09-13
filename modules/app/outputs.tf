output "aws_instance" {
  value = "${join(",", aws_instance.app.*.id)}"
}

output "aws_instance_ip" {
  value = "${join(",", aws_instance.app.*.private_ip)}"
}