data "aws_iam_policy_document" "notification_sender" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "SNS:Publish",
    ]

    resources = [
      "arn:aws:sns:${var.region}:${var.account_id}:${var.sns_topic_name}",
    ]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"

      values = [
        "arn:aws:lambda:${var.region}:${var.account_id}:${var.lambda_name}",
      ]
    }
  }
}