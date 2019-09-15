output "region" {
  value = "${local.region}"
}

output "db_table_name" {
  value = "${module.database.db_table_name}"
}

output "api_gateway_url" {
  value = "${module.api_gateway.api_gateway_url}"
}