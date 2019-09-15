data "aws_caller_identity" "current" {}

locals {
  owner      = "${var.owner}"
  env        = "${var.env}"
  region     = "eu-west-1"
  prefix     = "${upper(local.owner)}-${upper(local.env)}"
  account_id = "${data.aws_caller_identity.current.account_id}"

  tags = {
    owner    = "${local.owner}"
    workshop = "terratest"
  }

  gateway = {
    api_gateway_name        = "${local.prefix}-OrdersGateway"
    api_gateway_description = "Orders API - Terratest workshop example"
    api_gateway_path_part   = "orders"
  }

  compute = {
    create_order_function_name        = "${local.prefix}-CreateOrder"
    create_order_function_description = "This function inserts data in DynamoDB table"
    create_order_function_source_file = "../../source/lambda/create-order/lambda_function.py"

    orders_queue_name = "${local.prefix}-Orders"
  }

  database = {
    table_name = "${lower(local.prefix)}-terratest-workshop"
  }
}