// Security Group Resource for Module

resource "aws_security_group" "rds_security_group" {
    name = "${var.security_group_name}"
    description = "Security Group for ${var.security_group_name}"
    vpc_id = "${var.vpc_id}"

    // allows traffic from the SG itself for tcp
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }

    // allows traffic from the SG itself for udp
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        self = true
    }

    // allow traffic from bation host
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${var.bastion_security_group}"]
    }

    // allow traffic from application node
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = ["${var.application_security_group}"]
    }

    // allow node to call out
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.source_cidr_block}"]
    }
    tags {
        Name = "RDS security group"
    }
}