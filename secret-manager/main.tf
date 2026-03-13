#############################################
# PROVIDER
#############################################

provider "aws" {
  region = "ap-south-1"
}

#############################################
# KMS KEY FOR SECRET ENCRYPTION
#############################################

resource "aws_kms_key" "secret_kms_key" {

  description             = "KMS key for encrypting secrets"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "terraform-secret-kms-key"
    Environment = "dev"
    Owner       = "rameshwar"
  }

}

#############################################
# KMS ALIAS
#############################################

resource "aws_kms_alias" "secret_kms_alias" {

  name          = "alias/terraform-secret-key"
  target_key_id = aws_kms_key.secret_kms_key.key_id

}

#############################################
# SECRETS MANAGER SECRET
#############################################

resource "aws_secretsmanager_secret" "app_secret" {

  name        = "terraform-demo-secret"
  description = "Application credentials stored in AWS Secrets Manager"

  kms_key_id = aws_kms_key.secret_kms_key.arn

  recovery_window_in_days = 7

  force_overwrite_replica_secret = true

  tags = {
    Name        = "terraform-demo-secret"
    Environment = "dev"
    Owner       = "rameshwar"
    Terraform   = "true"
  }

}

#############################################
# SECRET VALUE
#############################################

resource "aws_secretsmanager_secret_version" "app_secret_value" {

  secret_id = aws_secretsmanager_secret.app_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = "StrongPassword123!"
    database = "mydb"
    host     = "mydb.example.internal"
  })

}

#############################################
# RESOURCE POLICY FOR SECRET
#############################################

resource "aws_secretsmanager_secret_policy" "secret_policy" {

  secret_arn = aws_secretsmanager_secret.app_secret.arn

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "AllowAccountAccess"

        Effect = "Allow"

        Principal = {
          AWS = "*"
        }

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = aws_secretsmanager_secret.app_secret.arn

      }

    ]

  })

}

#############################################
# OUTPUTS
#############################################

output "secret_name" {

  description = "Secrets Manager Secret Name"

  value = aws_secretsmanager_secret.app_secret.name

}

output "secret_arn" {

  description = "Secrets Manager Secret ARN"

  value = aws_secretsmanager_secret.app_secret.arn

}

output "kms_key_arn" {

  description = "KMS Key ARN used for secret encryption"

  value = aws_kms_key.secret_kms_key.arn

}
