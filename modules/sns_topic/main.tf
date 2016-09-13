resource "aws_sns_topic" "klassik" {
  name         = "${var.name}"
  display_name = "${var.display_name}"
}