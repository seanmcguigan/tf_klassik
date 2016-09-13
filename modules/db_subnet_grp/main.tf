resource "aws_db_subnet_group" "klassik" {
    name = "${var.name}"
    subnet_ids = ["${split(",", var.subnet_ids)}"]
    tags {
        Name = "klassik DB subnet group"
    }
}