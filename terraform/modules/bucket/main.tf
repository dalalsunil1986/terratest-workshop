resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}"
  force_destroy = true
  tags = "${var.tags}"
}

resource "aws_s3_bucket_notification" "this" {
  bucket = "${aws_s3_bucket.this.id}"

  lambda_function {
    lambda_function_arn = "${var.process_lambda_function_arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}

