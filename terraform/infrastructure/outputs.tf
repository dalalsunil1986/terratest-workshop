output "region" {
  value = "${local.region}"
}

output "db_table_name" {
  value = "${module.database.db_table_name}"
}

output "api_gateway_url" {
  value = "${module.api_gateway.api_gateway_url}"
}

output "sns_topic_arn" {
  value = "${module.notification.sns_topic_arn}"
}

output "sqs_queue_url" {
  value = "${module.compute.sqs_queue_url}"
}