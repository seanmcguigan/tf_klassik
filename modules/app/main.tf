resource "aws_instance" "app" {
    ami = "${var.ami}"
    count = "${var.count}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.security_groups}"]
    subnet_id = "${element(split(",", var.subnet_id), count.index)}"
    associate_public_ip_address = "${var.associate_public_ip_address}"
    source_dest_check = "${var.source_dest_check}"
    tags {
        Name = "klassik-app-${count.index}"
    }
}  