resource "aws_elb" "klassik" {
  name                  = "${var.name}"
  security_groups       = ["${var.security_groups}"]
  
  listener {
    instance_port       = "${var.instance_port}"
    instance_protocol   = "${var.instance_protocol}"
    lb_port             = "${var.lb_port}"
    lb_protocol         = "${var.lb_protocol}"
    ssl_certificate_id  = "${var.ssl_certificate_id}"
  }

  health_check {
    healthy_threshold   = "${var.healthy_threshold}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
    timeout             = "${var.timeout}"
    target              = "${var.target}"
    interval            = "${var.interval}"
  }

  instances                   = ["${split(",", var.instances)}"]
  subnets                     = ["${split(",", var.subnets)}"]
  cross_zone_load_balancing   = "${var.cross_zone_load_balancing}"
  idle_timeout                = "${var.idle_timeout}"
  connection_draining         = "${var.connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"

  tags {
    Name = "${var.tag_name}"
  }
}