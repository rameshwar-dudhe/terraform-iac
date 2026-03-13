# Terraform AWS Secrets Manager Example

This Terraform project creates a fully configured AWS Secrets Manager secret with encryption using a dedicated KMS key.

## Features

This project provisions:

- AWS KMS Key for encryption
- KMS Alias
- AWS Secrets Manager Secret
- Secret value stored as JSON
- Secret resource policy
- Terraform outputs for secret details

## Architecture

Terraform
   │
   ├── KMS Key
   │
   ├── Secrets Manager Secret
   │
   ├── Secret Version
   │
   └── Secret Policy

## Secret Structure

The secret stored in Secrets Manager is a JSON object:
