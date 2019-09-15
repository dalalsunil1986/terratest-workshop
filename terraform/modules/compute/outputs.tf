output "sqs_queue_name" {
  value = "${aws_sqs_queue.orders.name}"
}

output "sqs_queue_arn" {
  value = "${aws_sqs_queue.orders.arn}"
}

output "sqs_queue_url" {
  value = "${aws_sqs_queue.orders.id}"
}

output "create_order_function_name" {
  value = "${aws_lambda_function.create_order.function_name}"
}

output "create_order_function_arn" {
  value = "${aws_lambda_function.create_order.arn}"
}