output "region" {
  value = "${local.region}"
}

output "bucket_name" {
  value = "${module.bucket.bucket_name}"
}