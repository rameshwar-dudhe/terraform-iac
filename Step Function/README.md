# Terraform AWS Step Functions Example

This Terraform project deploys an AWS Step Functions workflow to automate EC2 instance start and stop operations.

## Architecture

Step Functions
   │
   ├── Lambda → Start EC2
   │
   ├── Wait State
   │
   └── Lambda → Stop EC2

## Components

This project creates:

- IAM role for Lambda
- IAM policy for EC2 access
- Lambda function
- IAM role for Step Functions
- Step Functions state machine

## Workflow

1. Step Function triggers Lambda
2. Lambda starts EC2 instance
3. Step Function waits 60 seconds
4. Lambda stops EC2 instance

## Prerequisites

- Terraform installed
- AWS CLI configured
- IAM permissions:
