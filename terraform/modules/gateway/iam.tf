data "aws_iam_policy_document" "api_gateway_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [
        "apigateway.amazonaws.com"
      ]
      type = "Service"
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "orders" {
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
    sid    = "AllowSensMessagesToQueue"
    effect = "Allow"

    resources = [
      "${var.sqs_queue_arn}",
    ]

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:CreateQueue",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "sqs_full_access" {
  role       = "${aws_iam_role.orders.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role" "orders" {
  name               = "${var.api_gateway_name}-IamRole"
  assume_role_policy = "${data.aws_iam_policy_document.api_gateway_trust_policy.json}"
  tags               = "${var.tags}"
}

resource "aws_iam_role_policy" "create_order" {
  name   = "${var.api_gateway_name}-IamPolicy"
  role   = "${aws_iam_role.orders.name}"
  policy = "${data.aws_iam_policy_document.orders.json}"
}