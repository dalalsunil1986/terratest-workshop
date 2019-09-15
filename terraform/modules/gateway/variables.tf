variable "region" {}
variable "env" {}
variable "account_id" {}
variable "tags" {
  type = "map"
}
variable "sqs_queue_name" {}
variable "sqs_queue_arn" {}
variable "api_gateway_name" {}
variable "api_gateway_description" {}
variable "api_gateway_path_part" {}