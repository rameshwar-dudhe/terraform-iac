provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "full_ec2" {

  # -------------------------
  # BASIC CONFIGURATION
  # -------------------------

  ami                         = "ami-0f5ee92e2d63afc18"
  instance_type               = "t3.medium"
  key_name                    = "my-keypair"
  availability_zone           = "ap-south-1a"
  tenancy                     = "default"
  host_id                     = null
  placement_group             = null

  monitoring                  = true
  ebs_optimized               = true

  instance_initiated_shutdown_behavior = "stop"

  disable_api_termination     = false
  disable_api_stop            = false

  iam_instance_profile        = "ec2-ssm-role"

  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker
EOF

  # -------------------------
  # NETWORK SETTINGS
  # -------------------------

  subnet_id                   = "subnet-0123456789abcdef0"
  private_ip                  = "10.0.1.50"

  secondary_private_ips = [
    "10.0.1.51",
    "10.0.1.52"
  ]

  associate_public_ip_address = true

  vpc_security_group_ids = [
    "sg-0123456789abcdef0"
  ]

  source_dest_check = true

  # -------------------------
  # CPU OPTIONS
  # -------------------------

  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }

  # -------------------------
  # CAPACITY RESERVATION
  # -------------------------

  capacity_reservation_specification {

    capacity_reservation_preference = "open"

  }

  # -------------------------
  # METADATA OPTIONS
  # -------------------------

  metadata_options {

    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"

  }

  # -------------------------
  # PRIVATE DNS OPTIONS
  # -------------------------

  private_dns_name_options {

    hostname_type                        = "ip-name"
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false

  }

  # -------------------------
  # ROOT VOLUME
  # -------------------------

  root_block_device {

    volume_type           = "gp3"
    volume_size           = 30
    iops                  = 3000
    throughput            = 125
    encrypted             = false
    delete_on_termination = true

  }

  # -------------------------
  # ADDITIONAL EBS VOLUME
  # -------------------------

  ebs_block_device {

    device_name           = "/dev/sdf"
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = false

  }

  # -------------------------
  # EPHEMERAL STORAGE
  # -------------------------

  ephemeral_block_device {

    device_name  = "/dev/sdb"
    virtual_name = "ephemeral0"

  }

  # -------------------------
  # TAGS
  # -------------------------

  tags = {

    Name        = "Terraform-Max-EC2"
    Environment = "Dev"
    Owner       = "Rameshwar"
    Project     = "DevOpsLab"
    Terraform   = "true"

  }

  volume_tags = {

    Name = "EC2-Root-Volume"

  }

}
