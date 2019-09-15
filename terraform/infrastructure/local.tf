locals {
  owner  = "${var.owner}"
  env    = "${var.env}"
  region = "eu-west-1"
  prefix = "${upper(local.owner)}-${upper(local.env)}"

  tags = {
    owner    = "${local.owner}"
    workshop = "terratest"
    Name     = "${local.ec2.name}"
  }

  ec2 = {
    name = "${lower(local.prefix)}-TerratestWorkshop"
    ami  = "ami-0bbc25e23a7640b9b"
    type = "t2.micro"
  }
}