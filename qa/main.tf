/* define the provider */

provider "aws" {
  region                   = "eu-west-1"
  profile                  = "klassik"
}

variable "opsgenie_api_key" {}
variable "database_username" {}
variable "database_password" {}

module "vpc" {
  source          = "../modules/vpc"
  name            = "klassik-vpc"
  cidr            = "10.0.0.0/16"
  private_subnets = "10.0.1.0/24,10.0.2.0/24,10.0.3.0/24"
  public_subnets  = "10.0.4.0/24,10.0.5.0/24,10.0.7.0/24"
  azs             = "eu-west-1a,eu-west-1b,eu-west-1c"
}

module "sg_app" {
  source                 = "../modules/sg_app"
  security_group_name    = "sg_app"
  vpc_id                 = "${module.vpc.vpc_id}"
  source_cidr_block      = "0.0.0.0/0"
  bastion_security_group = "${module.sg_bastion.security_group_id}"
  elb_security_group     = "${module.sg_elb.security_group_id}"
}

module "sg_elb" {
  source              = "../modules/sg_elb"
  security_group_name = "sg_elb"
  vpc_id              = "${module.vpc.vpc_id}"
  source_cidr_block   = "0.0.0.0/0"
}

module "sg_rds" {
  source                     = "../modules/sg_rds"
  security_group_name        = "sg_rds"
  vpc_id                     = "${module.vpc.vpc_id}"
  source_cidr_block          = "0.0.0.0/0"
  bastion_security_group     = "${module.sg_bastion.security_group_id}"
  application_security_group = "${module.sg_app.security_group_id}"
}

module "sg_bastion" {
  source              = "../modules/sg_bastion"
  security_group_name = "sg_bastion"
  vpc_id              = "${module.vpc.vpc_id}"
  source_cidr_block   = "0.0.0.0/0"
  restricted_access   = "84.233.151.236/32"
}

module "bastion_server" {
  source                      = "../modules/bastion_server"
  ami                         = "ami-f9dd458a" /* to be replaced with packer build */
  count                       = "1"
  instance_type               = "t2.small"
  key_name                    = "tf_klassik"
  security_groups             = "${module.sg_bastion.security_group_id}"
  subnet_id                   = "${module.vpc.public_subnets}"
  associate_public_ip_address = "true"
  source_dest_check           = "false"
}

module "app" {
  source                      = "../modules/app"
  ami                         = "ami-f9dd458a" /* to be replaced with packer build */
  count                       = "3"
  instance_type               = "t2.small"
  key_name                    = "tf_klassik"
  security_groups             = "${module.sg_app.security_group_id}"
  subnet_id                   = "${module.vpc.private_subnets}"
  associate_public_ip_address = "false"
  source_dest_check           = "false"
}

module "rds" {
  source              = "../modules/rds"
  project             = "klassik-platform"
  environment         = "qa"
  allocated_storage   = "32"
  engine_version      = "9.4.5"
  instance_type       = "db.t2.micro"
  storage_type        = "gp2"
  vpc_id              = "${module.vpc.vpc_id}"
  database_identifier = "db-id-klassik"
  database_name       = "klassik"
  database_password   = "${var.database_password}"
  database_username   = "${var.database_username}"
  database_port       = 5432
  backup_retention_period     = "7"
  backup_window               = "04:00-04:30"
  maintenance_window          = "sun:04:30-sun:05:30"
  auto_minor_version_upgrade  = true
  multi_availability_zone     = false
  storage_encrypted           = false
  subnet_group                = "${module.db_subnet_grp.grp_id}"
  db_sec_grp                  = "${module.sg_rds.security_group_id}"
  parameter_group             = ""
  alarm_cpu_threshold         = 85
  alarm_disk_queue_threshold  = 10
  alarm_free_disk_threshold   = 5000000000 //5GB
  alarm_free_memory_threshold = 128000000 //128MB
  alarm_actions               = "${module.sns_topic.arn}"
}

module "db_subnet_grp" {
  source     = "../modules/db_subnet_grp"
  name       = "qa_subnet_grp"
  subnet_ids = "${module.vpc.private_subnets}"
}  

module "sns_topic" {
  source       = "../modules/sns_topic"
  name         = "klassik"
  display_name = "klassik"
}

module "sns_subscriptions" {
  source                 = "../modules/sns_subscriptions"
  endpoint               = "${var.opsgenie_api_key}"
  endpoint_auto_confirms = "true"
  protocol               = "https"
  topic_arn              = "${module.sns_topic.arn}"
}

module "elb" {
  source              = "../modules/elb"
  name                = "klassik-elb"
  security_groups     = "${module.sg_elb.security_group_id}"
  instance_port       = "8080"
  instance_protocol   = "http"
  lb_port             = 443
  lb_protocol         = "https"
  ssl_certificate_id  = "arn:aws:iam::469564823659:server-certificate/klassik_uat_global_7digital_net"
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 3
  target              = "HTTP:8080/test"
  interval            = 30
  instances           = "${module.app.aws_instance}"
  subnets                     = "${module.vpc.public_subnets}"
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tag_name                    = "klassik elb"
}

module "dns" {
  source  = "../modules/dns"
  zone_id = "Z2XI64330TOW4G"
  name    = "klassik"
  type    = "CNAME"
  ttl     = "300"
  records = "${module.elb.elb_dns}"
}

module "autoscaling_groups" {
  source = "../modules/autoscaling_groups"
}

module "launch_congiuration" {
  source = "../modules/launch_congiuration"
}

/*  
   output references module outputs 
*/ 

output "vpc id" {
      value = "${module.vpc.vpc_id}"
}

output "private subnets" {
      value = "${module.vpc.private_subnets}"
}

output "public subnets" {
      value = "${module.vpc.public_subnets}"
}

output "public route table id" {
      value = "${module.vpc.public_route_table_id}"
}

output "private route table id" {
      value = "${module.vpc.private_route_table_id}"
}

output "nat gateway id" {
      value = "${module.vpc.aws_nat_gateway}"
}

output "database id" {
  value = "${module.rds.id}"
}

output "database hostname" {
  value = "${module.rds.hostname}"
}

output "elb dns name" {
  value = "${module.elb.elb_dns}"
}

output "bastion public ip address" {
  value = "${module.bastion_server.bastion_public_ip}"
}
