resource "aws_vpc" "klassik" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags { Name = "${var.name}" }
}

resource "aws_internet_gateway" "klassik" {
  vpc_id = "${aws_vpc.klassik.id}"
  tags { Name = "${var.name}-igw" }
}

/* If you have resources in multiple Availability Zones 
   and they share one NAT gateway, in the event that the 
   NAT gateway’s Availability Zone is down, resources in 
   the other Availability Zones lose Internet access. To 
   create an Availability Zone-independent architecture, 
   create a NAT gateway in each Availability Zone and configure 
   your routing to ensure that resources use the NAT gateway 
   in the same Availability Zone.
*/

resource "aws_eip" "nat" {
    vpc = true
}

/* place the nat gateway in ALL public subnets count the subnet ids */
resource "aws_nat_gateway" "gw" {
    allocation_id = "${aws_eip.nat.id}"
    depends_on    = ["aws_internet_gateway.klassik"]
    subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.klassik.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.klassik.id}"
  }
  tags { Name = "${var.name}-public-route" }
}

resource "aws_route_table_association" "public" {
  count          = "${length(compact(split(",", var.public_subnets)))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.klassik.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }
  tags { Name = "${var.name}-private-route" }
}

resource "aws_route_table_association" "private" {
  count          = "${length(compact(split(",", var.private_subnets)))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.klassik.id}"
  cidr_block        = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(compact(split(",", var.private_subnets)))}"
  tags { Name = "${var.name}-private-subnet" }
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.klassik.id}"
  cidr_block        = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(compact(split(",", var.public_subnets)))}"
  tags { Name = "${var.name}-public-subnet" }
  map_public_ip_on_launch = true
}