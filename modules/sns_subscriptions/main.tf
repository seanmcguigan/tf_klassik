resource "aws_sns_topic_subscription" "klassik_sub" {
  endpoint               = "${var.endpoint}"
  endpoint_auto_confirms = "${var.endpoint_auto_confirms}"
  protocol               = "${var.protocol}"
  topic_arn              = "${var.topic_arn}"
}