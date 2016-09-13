// Module specific variables
variable "security_group_name" {
  description = "The name for the security group"
}

variable "vpc_id" {
  description = "The VPC this security group will go in"
}

variable "source_cidr_block" {
  description = "The source CIDR block to allow traffic from"
}

variable "bastion_security_group" {
  description = "Allow traffic from bastion host"
}

variable "application_security_group" {
  description = "Allow traffic from bastion host"
}

