provider "aws" {
  region = "ap-south-1"
}

#################################
# VPC
#################################

resource "aws_vpc" "main_vpc" {

  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_network_address_usage_metrics = false

  tags = {
    Name        = "terraform-main-vpc"
    Environment = "dev"
    Owner       = "rameshwar"
  }

}

#################################
# DHCP OPTIONS
#################################

resource "aws_vpc_dhcp_options" "dhcp" {

  domain_name = "ap-south-1.compute.internal"

  domain_name_servers = [
    "AmazonProvidedDNS"
  ]

  ntp_servers = [
    "169.254.169.123"
  ]

  tags = {
    Name = "terraform-dhcp-options"
  }

}

resource "aws_vpc_dhcp_options_association" "dhcp_assoc" {

  vpc_id          = aws_vpc.main_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp.id

}

#################################
# INTERNET GATEWAY
#################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "terraform-igw"
  }

}

#################################
# PUBLIC SUBNET
#################################

resource "aws_subnet" "public_subnet" {

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"

  map_public_ip_on_launch = true

  enable_dns64            = false

  tags = {
    Name = "public-subnet"
  }

}

#################################
# PRIVATE SUBNET
#################################

resource "aws_subnet" "private_subnet" {

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }

}

#################################
# ELASTIC IP FOR NAT
#################################

resource "aws_eip" "nat_eip" {

  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }

}

#################################
# NAT GATEWAY
#################################

resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "terraform-nat"
  }

}

#################################
# PUBLIC ROUTE TABLE
#################################

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "public-route-table"
  }

}

#################################
# PRIVATE ROUTE TABLE
#################################

resource "aws_route_table" "private_rt" {

  vpc_id = aws_vpc.main_vpc.id

  route {

    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id

  }

  tags = {
    Name = "private-route-table"
  }

}

#################################
# ROUTE TABLE ASSOCIATIONS
#################################

resource "aws_route_table_association" "public_assoc" {

  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_route_table_association" "private_assoc" {

  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id

}

#################################
# NETWORK ACL
#################################

resource "aws_network_acl" "main_acl" {

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-network-acl"
  }

}

resource "aws_network_acl_rule" "allow_all_inbound" {

  network_acl_id = aws_network_acl.main_acl.id

  rule_number = 100
  egress      = false
  protocol    = "-1"

  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

}

resource "aws_network_acl_rule" "allow_all_outbound" {

  network_acl_id = aws_network_acl.main_acl.id

  rule_number = 100
  egress      = true
  protocol    = "-1"

  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

}

#################################
# FLOW LOGS
#################################

resource "aws_cloudwatch_log_group" "vpc_logs" {

  name = "vpc-flow-logs"

}

resource "aws_flow_log" "vpc_flow_log" {

  log_destination      = aws_cloudwatch_log_group.vpc_logs.arn
  log_destination_type = "cloud-watch-logs"

  traffic_type = "ALL"

  vpc_id = aws_vpc.main_vpc.id

}
