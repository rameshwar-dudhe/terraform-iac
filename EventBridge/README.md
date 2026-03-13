# Terraform AWS EventBridge Scheduler for EC2 Automation

This Terraform project deploys AWS EventBridge rules to automatically start and stop EC2 instances using AWS Lambda.

## Architecture

Terraform
   │
   ├── EventBridge Rule (Start)
   ├── EventBridge Rule (Stop)
   │
   ├── EventBridge Target
   │
   └── Lambda Invocation

EventBridge triggers Lambda using a scheduled cron expression.

## Automation Schedule

Start EC2: 08:00 AM daily  
Stop EC2: 07:00 PM daily  

## Components

This project creates:

- EventBridge rule for EC2 start
- EventBridge rule for EC2 stop
- EventBridge targets
- Lambda invocation permissions

## Prerequisites

Before deploying ensure:

- Terraform installed
- AWS CLI configured
- Lambda function already deployed

Required IAM permissions:
