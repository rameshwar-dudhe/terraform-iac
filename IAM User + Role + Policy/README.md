# Terraform IAM User, Role and Policy Example

This Terraform project creates AWS IAM resources including a user, role, and custom IAM policy.

## Resources Created

- IAM User
- IAM Access Key
- IAM Role
- Custom IAM Policy
- Policy attachment to User
- Policy attachment to Role

## Architecture

Terraform
   │
   ├── IAM User
   │    └── Access Key
   │
   ├── IAM Role
   │
   └── IAM Policy
        ├── Attached to User
        └── Attached to Role

## Permissions in Policy

The policy allows:

### EC2

- Describe instances
- Start instances
- Stop instances

### S3

- List bucket
- Upload objects
- Download objects

## Prerequisites

- Terraform installed
- AWS CLI configured
- IAM permissions

Required permissions:
