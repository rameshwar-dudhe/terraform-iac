############################################
# PROVIDER
############################################

provider "aws" {
  region = "ap-south-1"
}

############################################
# IAM USER
############################################

resource "aws_iam_user" "devops_user" {

  name = "terraform-devops-user"

  path = "/"

  tags = {
    Name        = "devops-user"
    Environment = "dev"
    Owner       = "rameshwar"
  }

}

############################################
# ACCESS KEY FOR USER
############################################

resource "aws_iam_access_key" "devops_user_key" {

  user = aws_iam_user.devops_user.name

}

############################################
# IAM ROLE
############################################

resource "aws_iam_role" "devops_role" {

  name = "terraform-devops-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"

      }

    ]

  })

  tags = {
    Name = "devops-role"
  }

}

############################################
# CUSTOM IAM POLICY
############################################

resource "aws_iam_policy" "devops_policy" {

  name = "terraform-devops-policy"

  description = "Policy for EC2 and S3 access"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]

        Resource = "*"

      },

      {

        Effect = "Allow"

        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "*"

      }

    ]

  })

  tags = {
    Name = "devops-policy"
  }

}

############################################
# ATTACH POLICY TO ROLE
############################################

resource "aws_iam_role_policy_attachment" "role_policy_attach" {

  role       = aws_iam_role.devops_role.name
  policy_arn = aws_iam_policy.devops_policy.arn

}

############################################
# ATTACH POLICY TO USER
############################################

resource "aws_iam_user_policy_attachment" "user_policy_attach" {

  user       = aws_iam_user.devops_user.name
  policy_arn = aws_iam_policy.devops_policy.arn

}

############################################
# OUTPUTS
############################################

output "iam_user_name" {

  value = aws_iam_user.devops_user.name

}

output "iam_user_access_key" {

  value = aws_iam_access_key.devops_user_key.id

}

output "iam_user_secret_key" {

  value     = aws_iam_access_key.devops_user_key.secret
  sensitive = true

}

output "iam_role_name" {

  value = aws_iam_role.devops_role.name

}

output "iam_policy_arn" {

  value = aws_iam_policy.devops_policy.arn

}
