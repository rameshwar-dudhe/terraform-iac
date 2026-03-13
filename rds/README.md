# Terraform RDS Deployment

This project provisions a fully configured Amazon RDS MySQL database using Terraform.

## Resources Created

- Security Group for RDS
- DB Subnet Group
- DB Parameter Group
- DB Option Group
- RDS MySQL Instance
- CloudWatch Log Export
- Performance Insights
- Outputs for endpoint and instance ID

## Architecture

Terraform
   │
   ├── Security Group
   ├── DB Subnet Group
   ├── Parameter Group
   ├── Option Group
   └── RDS Instance

## Configuration

Database Engine: MySQL 8.0  
Instance Type: db.t3.micro  
Storage: 20GB gp3  
Backup Retention: 7 days  
Multi AZ: Disabled  

## Deployment Steps

Initialize Terraform
