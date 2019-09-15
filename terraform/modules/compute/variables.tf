variable "region" {}
variable "account_id" {}
variable "tags" {
  type = "map"
}
variable "create_order_function_name" {}
variable "create_order_function_description" {}
variable "create_order_function_source_file" {}
variable "orders_queue_name" {}
variable "sns_topic_name" {}
variable "db_table_name" {}
variable "db_table_arn" {}