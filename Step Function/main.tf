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

  name = "terraform-stepfunction-lambda-role"

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
          "logs:*"
        ]

        Resource = "*"
      }

    ]

  })

}

############################################
# LAMBDA ZIP
############################################

data "archive_file" "lambda_zip" {

  type = "zip"

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

    if action == "stop":
        ec2.stop_instances(InstanceIds=[INSTANCE_ID])
        return "Instance stopped"
EOF

    filename = "lambda_function.py"

  }

}

############################################
# LAMBDA FUNCTION
############################################

resource "aws_lambda_function" "ec2_lambda" {

  function_name = "stepfunction-ec2-controller"

  role = aws_iam_role.lambda_role.arn

  handler = "lambda_function.lambda_handler"

  runtime = "python3.11"

  filename = data.archive_file.lambda_zip.output_path

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

}

############################################
# IAM ROLE FOR STEP FUNCTION
############################################

resource "aws_iam_role" "step_function_role" {

  name = "terraform-step-function-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {
          Service = "states.amazonaws.com"
        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

############################################
# POLICY FOR STEP FUNCTION
############################################

resource "aws_iam_role_policy" "step_function_policy" {

  role = aws_iam_role.step_function_role.id

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Action = [
          "lambda:InvokeFunction"
        ]

        Resource = "*"

      }

    ]

  })

}

############################################
# STEP FUNCTION STATE MACHINE
############################################

resource "aws_sfn_state_machine" "ec2_workflow" {

  name     = "terraform-ec2-automation"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({

    Comment = "EC2 start and stop workflow"

    StartAt = "StartEC2"

    States = {

      StartEC2 = {

        Type = "Task"

        Resource = aws_lambda_function.ec2_lambda.arn

        Parameters = {
          action = "start"
        }

        Next = "WaitState"

      }

      WaitState = {

        Type = "Wait"

        Seconds = 60

        Next = "StopEC2"

      }

      StopEC2 = {

        Type = "Task"

        Resource = aws_lambda_function.ec2_lambda.arn

        Parameters = {
          action = "stop"
        }

        End = true

      }

    }

  })

}

############################################
# OUTPUTS
############################################

output "step_function_name" {

  value = aws_sfn_state_machine.ec2_workflow.name

}

output "step_function_arn" {

  value = aws_sfn_state_machine.ec2_workflow.arn

}

output "lambda_function_name" {

  value = aws_lambda_function.ec2_lambda.function_name

}
