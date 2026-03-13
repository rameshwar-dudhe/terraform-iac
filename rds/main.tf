provider "aws" {
  region = "ap-south-1"
}

########################################
# VPC SECURITY GROUP FOR RDS
########################################

resource "aws_security_group" "rds_sg" {

  name        = "terraform-rds-sg"
  description = "Allow MySQL access"
  vpc_id      = "vpc-0123456789abcdef0"

  ingress {

    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "terraform-rds-sg"
  }

}

########################################
# DB SUBNET GROUP
########################################

resource "aws_db_subnet_group" "rds_subnet_group" {

  name = "terraform-rds-subnet-group"

  subnet_ids = [
    "subnet-0123456789abcdef0",
    "subnet-0fedcba9876543210"
  ]

  description = "Subnet group for RDS"

  tags = {
    Name = "terraform-rds-subnet-group"
  }

}

########################################
# PARAMETER GROUP
########################################

resource "aws_db_parameter_group" "rds_parameter_group" {

  name   = "terraform-rds-parameter-group"
  family = "mysql8.0"

  parameter {

    name  = "max_connections"
    value = "200"

  }

  parameter {

    name  = "slow_query_log"
    value = "1"

  }

  tags = {
    Name = "terraform-rds-parameter-group"
  }

}

########################################
# OPTION GROUP
########################################

resource "aws_db_option_group" "rds_option_group" {

  name                     = "terraform-rds-option-group"
  option_group_description = "Terraform RDS Option Group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"

}

########################################
# RDS INSTANCE
########################################

resource "aws_db_instance" "mysql_rds" {

  identifier = "terraform-rds-instance"

  #################################
  # ENGINE
  #################################

  engine         = "mysql"
  engine_version = "8.0"

  #################################
  # INSTANCE SIZE
  #################################

  instance_class = "db.t3.micro"

  #################################
  # STORAGE
  #################################

  allocated_storage     = 20
  max_allocated_storage = 100

  storage_type = "gp3"

  storage_encrypted = false

  #################################
  # DATABASE
  #################################

  db_name  = "mydatabase"
  username = "admin"
  password = "MyStrongPassword123!"

  port = 3306

  #################################
  # NETWORK
  #################################

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = true

  multi_az = false

  #################################
  # BACKUP
  #################################

  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  #################################
  # MAINTENANCE
  #################################

  maintenance_window = "Mon:04:00-Mon:05:00"

  #################################
  # MONITORING
  #################################

  monitoring_interval = 60

  performance_insights_enabled = true

  #################################
  # LOG EXPORT
  #################################

  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]

  #################################
  # PARAMETER / OPTION GROUP
  #################################

  parameter_group_name = aws_db_parameter_group.rds_parameter_group.name
  option_group_name    = aws_db_option_group.rds_option_group.name

  #################################
  # DELETION SETTINGS
  #################################

  skip_final_snapshot = true
  deletion_protection = false

  #################################
  # AUTO MINOR VERSION UPGRADE
  #################################

  auto_minor_version_upgrade = true

  #################################
  # TAGS
  #################################

  tags = {

    Name        = "terraform-rds"
    Environment = "dev"
    Owner       = "rameshwar"

  }

}

########################################
# OUTPUTS
########################################

output "rds_endpoint" {

  description = "RDS Endpoint"
  value       = aws_db_instance.mysql_rds.endpoint

}

output "rds_identifier" {

  description = "RDS Instance ID"
  value       = aws_db_instance.mysql_rds.id

}

output "rds_port" {

  value = aws_db_instance.mysql_rds.port

}
