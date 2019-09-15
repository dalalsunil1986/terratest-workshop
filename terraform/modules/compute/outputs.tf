output "sqs_queue_name" {
  value = "${aws_sqs_queue.orders.name}"
}
output "sqs_queue_arn" {
  value = "${aws_sqs_queue.orders.arn}"
}