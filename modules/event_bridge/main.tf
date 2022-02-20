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
  target_id = "SendToSNS"
  arn       = aws_sns_topic.aws_logins.arn
  depends_on = [aws_sns_topic.aws_logins]
}

resource "aws_sns_topic" "aws_logins" {
  name = "aws-console-logins"
}


resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.aws_logins.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}


data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.aws_logins.arn]
  }
}
