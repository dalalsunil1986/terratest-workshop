data "archive_file" "process_file" {
  type        = "zip"
  source_file = "${var.process_lambda_source_file}"
  output_path = "../../output/lambda.zip"
}

resource "aws_lambda_permission" "process_file" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.process_file.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.bucket_arn}"
}

resource "aws_lambda_function" "process_file" {
  function_name    = "${var.process_lambda_name}"
  handler          = "lambda_function.handler"
  runtime          = "python3.7"
  timeout          = 5
  role             = "${aws_iam_role.process_file.arn}"
  filename         = "${data.archive_file.process_file.output_path}"
  source_code_hash = "${data.archive_file.process_file.output_base64sha256}"
  tags             = "${var.tags}"
}