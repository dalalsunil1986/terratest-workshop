data "archive_file" "create_order" {
  type        = "zip"
  source_file = "${var.create_order_function_source_file}"
  output_path = "../../output/create_order_lambda.zip"
}

resource "aws_lambda_event_source_mapping" "create_order" {
  event_source_arn = "${aws_sqs_queue.orders.arn}"
  enabled          = true
  function_name    = "${aws_lambda_function.create_order.arn}"
  batch_size       = 10
}

resource "aws_lambda_function" "create_order" {
  function_name    = "${var.create_order_function_name}"
  description      = "${var.create_order_function_description}"
  handler          = "lambda_function.handler"
  runtime          = "python3.7"
  role             = "${aws_iam_role.create_order.arn}"
  filename         = "${data.archive_file.create_order.output_path}"
  source_code_hash = "${data.archive_file.create_order.output_base64sha256}"
  tags             = "${var.tags}"

  environment {
    variables = {
      DB_TABLE_NAME = "${var.db_table_name}"
      SNS_NOTIFICATION_TOPIC_ARN = "${local.sns_topic_arn}"
    }
  }
}