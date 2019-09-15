data "aws_caller_identity" "current" {}

locals {
  owner      = "${var.owner}"
  env        = "${var.env}"
  region     = "eu-west-1"
  prefix     = "${upper(local.owner)}-${upper(local.env)}"
  account_id = "${data.aws_caller_identity.current.account_id}"

  tags = {
    owner    = "${local.owner}"
    workshop = "terratest"
  }

  bucket = {
    name = "${lower(local.prefix)}-terratest-workshop"
  }

  process_lambda = {
    name = "${local.prefix}-ProcessFile"
    source_file = "../../source/lambda/process-file/lambda_function.py"
  }
}