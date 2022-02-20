resource "aws_cloudwatch_event_rule" "event_bridge" {
  name        = "demo-macie-slack-notifer-event-rule"
  description = "Rule that captures AWS Macie findings"

  event_pattern = <<EOF
{
  "source": ["aws.macie"],
  "detail-type": ["Macie Finding"]
}
EOF
}

resource "aws_cloudwatch_event_target" "check_eb_every_one_minute" {
  rule      = aws_cloudwatch_event_rule.event_bridge.name
  target_id = "test_lambda"
  arn       = "${aws_lambda_function.test_lambda.arn}"
  depends_on = [aws_lambda_function.test_lambda]
    
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.lambda_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
			"Sid": "AllowInvokeItself",
			"Effect": "Allow",
			"Action": [
				"lambda:InvokeFunction"
			],
			"Resource": [
				"${aws_lambda_function.test_lambda.arn}"
			]
		},
		{
			"Sid": "Stmt1645030795612",
			"Action": "events:*",
			"Effect": "Allow",
			"Resource": "*"
		}
	]
}
EOF
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

locals {
  lambda_zip_location = "outputs/welcome.zip"
}

data "archive_file" "welcome" {
  type        = "zip"
  source_file = "${path.module}/welcome.py"
  output_path = "${local.lambda_zip_location}"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${local.lambda_zip_location}"
  function_name = "welcome"
  role          = aws_iam_role.lambda_role.arn
  handler       = "welcome.hello"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  #source_code_hash = filebase64sha256("local.lambda_zip_location")

  runtime = "python3.7"

#  environment {
#    variables = {
#      foo = "bar"
#    }
#  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.event_bridge.arn}"
}


