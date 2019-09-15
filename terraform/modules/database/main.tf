resource "aws_dynamodb_table" "orders" {
  name           = "${var.db_table_name}"
  hash_key       = "Item"
  read_capacity  = "${var.db_read_capacity}"
  write_capacity = "${var.db_write_capacity}"

  attribute {
    name = "Item"
    type = "S"
  }

  tags = "${var.tags}"
}