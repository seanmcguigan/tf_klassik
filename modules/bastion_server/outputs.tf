output "bastion_public_ip" {
  value = "${join(",", aws_instance.bastion.*.public_ip)}"
}