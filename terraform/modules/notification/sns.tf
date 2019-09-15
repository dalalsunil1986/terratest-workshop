resource "aws_sns_topic" "notification_sender" {
  name   = "${var.sns_topic_name}"
  policy = "${data.aws_iam_policy_document.notification_sender.json}"
  tags   = "${var.tags}"
}