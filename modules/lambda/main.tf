resource "aws_iam_role" "lambda_role" {
  name = "lambda-failover-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-failover-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "ec2:DescribeAddresses",
          "ec2:DescribeInstances",    
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress"   
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "failover" {
  filename         = "${path.module}/lambda_failover.zip"
  function_name    = "eip_failover"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_failover.lambda_handler"
  runtime          = "python3.9"
  timeout          = 10
  source_code_hash = filebase64sha256("${path.module}/lambda_failover.zip")

  environment {
    variables = {
      EIP              = var.eip
      ACTIVE_INSTANCE  = var.active_instance_id
      PASSIVE_INSTANCE = var.passive_instance_id
    }
  }
}

resource "aws_cloudwatch_event_rule" "ec2_instance_state_change" {
  name        = "ec2-instance-state-change-rule"
  description = "Trigger Lambda on EC2 instance state changes"
  event_pattern = jsonencode({
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
      "state": ["stopped", "terminated", "stopping"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.ec2_instance_state_change.name
  target_id = "send-to-lambda"
  arn       = aws_lambda_function.failover.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_instance_state_change.arn
}
