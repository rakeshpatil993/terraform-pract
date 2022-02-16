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
  target_id = "lambda"
  arn       = "${aws_lambda_function.lambda.arn}"
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.event_bridge.arn}"
}

