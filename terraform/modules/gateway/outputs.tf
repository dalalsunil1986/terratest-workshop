output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.orders.invoke_url}/${var.api_gateway_path_part}"
}