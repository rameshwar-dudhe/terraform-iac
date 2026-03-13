# Terraform Lambda EC2 Start/Stop Automation

This Terraform project deploys an AWS Lambda function that can start or stop an EC2 instance.

## Architecture

Terraform
   │
   ├── IAM Role
   ├── IAM Policy
   ├── Lambda Function
   └── CloudWatch Logs

Lambda uses boto3 to control EC2 instances.

## Features

- Start EC2 instance
- Stop EC2 instance
- Fully automated deployment
- IAM role with required permissions
- Python Lambda function

## Prerequisites

- Terraform installed
- AWS CLI configured
- IAM permissions for:
