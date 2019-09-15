module "api_gateway" {
  source                  = "../modules/gateway"
  region                  = "${local.region}"
  account_id              = "${local.account_id}"
  env                     = "${local.env}"
  sqs_queue_name          = "${module.compute.sqs_queue_name}"
  sqs_queue_arn           = "${module.compute.sqs_queue_arn}"
  api_gateway_name        = "${local.gateway.api_gateway_name}"
  api_gateway_description = "${local.gateway.api_gateway_description}"
  api_gateway_path_part   = "${local.gateway.api_gateway_path_part}"
  tags                    = "${local.tags}"
}

module "compute" {
  source                            = "../modules/compute"
  account_id = "${local.account_id}"
  region = "${local.region}"
  create_order_function_name        = "${local.compute.create_order_function_name}"
  create_order_function_description = "${local.compute.create_order_function_description}"
  create_order_function_source_file = "${local.compute.create_order_function_source_file}"
  orders_queue_name                 = "${local.compute.orders_queue_name}"
  sns_topic_name                    = "${local.notification.topic_name}"
  db_table_name                     = "${module.database.db_table_name}"
  db_table_arn                      = "${module.database.db_table_arn}"
  tags                              = "${local.tags}"
}

module "database" {
  source            = "../modules/database"
  db_table_name     = "${local.database.table_name}"
  db_read_capacity  = 5
  db_write_capacity = 5
  tags              = "${local.tags}"
}

module "notification" {
  source            = "../modules/notification"
  account_id = "${local.account_id}"
  region = "${local.region}"
  lambda_name = "${module.compute.create_order_function_name}"
  lambda_arn = "${module.compute.create_order_function_arn}"
  sns_topic_name = "${local.notification.topic_name}"
  tags              = "${local.tags}"
}

