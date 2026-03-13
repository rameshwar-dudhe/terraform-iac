############################################
# PROVIDER
############################################

provider "aws" {
  region = "ap-south-1"
}

############################################
# IAM ROLE FOR LAMBDA
############################################

resource "aws_iam_role" "lambda_role" {

  name = "terraform-lambda-ec2-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

############################################
# IAM POLICY FOR EC2 CONTROL
############################################

resource "aws_iam_role_policy" "lambda_ec2_policy" {

  name = "lambda-ec2-control-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      }

    ]

  })

}

############################################
# LAMBDA ZIP PACKAGE
############################################

data "archive_file" "lambda_zip" {

  type        = "zip"
  output_path = "lambda_function.zip"

  source {

    content = <<EOF
import boto3

ec2 = boto3.client('ec2')

INSTANCE_ID = "i-0123456789abcdef0"

def lambda_handler(event, context):

    action = event.get("action")

    if action == "start":
        ec2.start_instances(InstanceIds=[INSTANCE_ID])
        return "Instance started"

    elif action == "stop":
        ec2.stop_instances(InstanceIds=[INSTANCE_ID])
        return "Instance stopped"

    else:
        return "Invalid action"
EOF

    filename = "lambda_function.py"

  }

}

############################################
# LAMBDA FUNCTION
############################################

resource "aws_lambda_function" "ec2_control_lambda" {

  function_name = "terraform-ec2-start-stop"

  role    = aws_iam_role.lambda_role.arn
  handler = "lambda_function.lambda_handler"

  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 10
  memory_size = 128

  tags = {
    Name        = "ec2-control-lambda"
    Environment = "dev"
  }

}

############################################
# OUTPUTS
############################################

output "lambda_function_name" {

  value = aws_lambda_function.ec2_control_lambda.function_name

}

output "lambda_function_arn" {

  value = aws_lambda_function.ec2_control_lambda.arn

}
