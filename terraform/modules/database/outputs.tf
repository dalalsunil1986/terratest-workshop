output "db_table_name" {
  value = "${aws_dynamodb_table.orders.name}"
}

output "db_table_arn" {
  value = "${aws_dynamodb_table.orders.arn}"
}