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

data "aws_iam_policy_document" "create_order" {
  statement {
    sid    = "AllowWritingLogs"
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:*",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid    = "AllowSQSPermissions"
    effect = "Allow"

    resources = [
      "${aws_sqs_queue.orders.arn}"
    ]

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid    = "AllowDynamodbPutItem"
    effect = "Allow"

    resources = [
      "${var.db_table_arn}",
    ]

    actions = [
      "dynamodb:PutItem",
    ]
  }
}

resource "aws_iam_role" "create_order" {
  name               = "${var.create_order_function_name}-IamRole"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_trust_policy.json}"
  tags               = "${var.tags}"
}

resource "aws_iam_role_policy" "create_order" {
  name   = "${var.create_order_function_name}-IamPolicy"
  role   = "${aws_iam_role.create_order.name}"
  policy = "${data.aws_iam_policy_document.create_order.json}"
}