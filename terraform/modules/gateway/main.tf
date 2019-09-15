data "template_file" "orders" {
  template = "${file("${path.module}/rest_template.tpl")}"
}

resource "aws_api_gateway_rest_api" "orders" {
  name        = "${var.api_gateway_name}"
  description = "${var.api_gateway_description}"
}

resource "aws_api_gateway_resource" "orders" {
  rest_api_id = "${aws_api_gateway_rest_api.orders.id}"
  parent_id   = "${aws_api_gateway_rest_api.orders.root_resource_id}"
  path_part   = "${var.api_gateway_path_part}"
}

resource "aws_api_gateway_method" "orders" {
  rest_api_id   = "${aws_api_gateway_rest_api.orders.id}"
  resource_id   = "${aws_api_gateway_resource.orders.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration_response" "orders" {
  http_method = "${aws_api_gateway_method_response.orders.http_method}"
  resource_id = "${aws_api_gateway_resource.orders.id}"
  rest_api_id = "${aws_api_gateway_rest_api.orders.id}"
  status_code = "${aws_api_gateway_method_response.orders.status_code}"
}

resource "aws_api_gateway_integration" "orders" {
  rest_api_id             = "${aws_api_gateway_rest_api.orders.id}"
  resource_id             = "${aws_api_gateway_resource.orders.id}"
  http_method             = "${aws_api_gateway_method.orders.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${var.account_id}/${var.sqs_queue_name}"
  credentials             = "${aws_iam_role.orders.arn}"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "${data.template_file.orders.rendered}"
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_method_response" "orders" {
  rest_api_id = "${aws_api_gateway_rest_api.orders.id}"
  resource_id = "${aws_api_gateway_resource.orders.id}"
  http_method = "${aws_api_gateway_method.orders.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_deployment" "orders" {
  depends_on  = ["aws_api_gateway_integration.orders"]
  rest_api_id = "${aws_api_gateway_rest_api.orders.id}"
  stage_name  = "${var.env}"
}