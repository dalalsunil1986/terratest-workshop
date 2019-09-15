resource "aws_sqs_queue" "orders" {
  name = "${var.orders_queue_name}"
  tags = "${var.tags}"
}