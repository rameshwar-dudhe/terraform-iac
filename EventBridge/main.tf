############################################
# PROVIDER
############################################

provider "aws" {
  region = "ap-south-1"
}

############################################
# EVENTBRIDGE RULE (STOP INSTANCE AT NIGHT)
############################################

resource "aws_cloudwatch_event_rule" "stop_ec2_rule" {

  name        = "terraform-stop-ec2-rule"
  description = "Stop EC2 instance every night"

  schedule_expression = "cron(0 19 * * ? *)"

  is_enabled = true

  tags = {

    Name        = "stop-ec2-rule"
    Environment = "dev"

  }

}

############################################
# EVENTBRIDGE RULE (START INSTANCE MORNING)
############################################

resource "aws_cloudwatch_event_rule" "start_ec2_rule" {

  name        = "terraform-start-ec2-rule"
  description = "Start EC2 instance every morning"

  schedule_expression = "cron(0 8 * * ? *)"

  is_enabled = true

  tags = {

    Name = "start-ec2-rule"

  }

}

############################################
# EVENTBRIDGE TARGET (STOP)
############################################

resource "aws_cloudwatch_event_target" "stop_lambda_target" {

  rule = aws_cloudwatch_event_rule.stop_ec2_rule.name

  arn = "arn:aws:lambda:ap-south-1:123456789012:function:terraform-ec2-start-stop"

  target_id = "StopEC2Lambda"

  input = jsonencode({
    action = "stop"
  })

}

############################################
# EVENTBRIDGE TARGET (START)
############################################

resource "aws_cloudwatch_event_target" "start_lambda_target" {

  rule = aws_cloudwatch_event_rule.start_ec2_rule.name

  arn = "arn:aws:lambda:ap-south-1:123456789012:function:terraform-ec2-start-stop"

  target_id = "StartEC2Lambda"

  input = jsonencode({
    action = "start"
  })

}

############################################
# LAMBDA PERMISSION FOR EVENTBRIDGE
############################################

resource "aws_lambda_permission" "allow_eventbridge_stop" {

  statement_id  = "AllowExecutionFromEventBridgeStop"
  action        = "lambda:InvokeFunction"

  function_name = "terraform-ec2-start-stop"

  principal = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.stop_ec2_rule.arn

}

resource "aws_lambda_permission" "allow_eventbridge_start" {

  statement_id  = "AllowExecutionFromEventBridgeStart"
  action        = "lambda:InvokeFunction"

  function_name = "terraform-ec2-start-stop"

  principal = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.start_ec2_rule.arn

}

############################################
# OUTPUTS
############################################

output "eventbridge_stop_rule" {

  description = "Stop EC2 EventBridge Rule"

  value = aws_cloudwatch_event_rule.stop_ec2_rule.name

}

output "eventbridge_start_rule" {

  description = "Start EC2 EventBridge Rule"

  value = aws_cloudwatch_event_rule.start_ec2_rule.name

}
