data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "process_file" {
  statement {
    sid    = "AllowCloudWatchLogging"
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:*"
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid    = "AllowBucketGetAndPutObject"
    effect = "Allow"

    resources = [
      "${var.bucket_arn}",
      "${var.bucket_arn}/*",
    ]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
  }
}

resource "aws_iam_policy" "process_file" {
  name   = "${var.process_lambda_name}-IamPolicy"
  policy = "${data.aws_iam_policy_document.process_file.json}"
}

resource "aws_iam_role_policy_attachment" "process_file" {
  role       = "${aws_iam_role.process_file.name}"
  policy_arn = "${aws_iam_policy.process_file.arn}"
}

resource "aws_iam_role" "process_file" {
  name               = "${var.process_lambda_name}-IamRole"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_trust_policy.json}"
  tags               = "${var.tags}"
}