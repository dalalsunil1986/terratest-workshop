locals {
  sns_topic_arn = "arn:aws:sns:${var.region}:${var.account_id}:${var.sns_topic_name}"
}