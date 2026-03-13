provider "aws" {
  region = "ap-south-1"
}

#################################
# ELASTIC IP
#################################

resource "aws_eip" "my_eip" {

  domain = "vpc"

  tags = {
    Name        = "terraform-eip"
    Environment = "dev"
    Owner       = "rameshwar"
  }

}

#################################
# EC2 INSTANCE
#################################

resource "aws_instance" "example_ec2" {

  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"

  subnet_id = "subnet-0123456789abcdef0"

  vpc_security_group_ids = [
    "sg-0123456789abcdef0"
  ]

  key_name = "my-keypair"

  tags = {
    Name = "terraform-ec2"
  }

}

#################################
# EIP ASSOCIATION
#################################

resource "aws_eip_association" "eip_attach" {

  instance_id   = aws_instance.example_ec2.id
  allocation_id = aws_eip.my_eip.id

}

#################################
# OUTPUTS
#################################

output "elastic_ip_address" {

  description = "Elastic IP Public Address"
  value       = aws_eip.my_eip.public_ip

}

output "elastic_ip_allocation_id" {

  description = "Elastic IP Allocation ID"
  value       = aws_eip.my_eip.id

}

output "ec2_instance_id" {

  description = "EC2 Instance ID"
  value       = aws_instance.example_ec2.id

}
