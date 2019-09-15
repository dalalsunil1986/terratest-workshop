module "process_lambda" {
  source                     = "../modules/lambda"
  process_lambda_name        = "${local.process_lambda.name}"
  process_lambda_source_file = "${local.process_lambda.source_file}"
  bucket_arn                 = "${module.bucket.bucket_arn}"
  tags                       = "${local.tags}"
}

module "bucket" {
  source                      = "../modules/bucket"
  tags                        = "${local.tags}"
  process_lambda_function_arn = "${module.process_lambda.process_file_arn}"
  bucket_name                 = "${local.bucket.name}"
}
