module "web_server" {
  source        = "../modules/ec2"
  instance_name = "${local.ec2.name}"
  instance_type = "${local.ec2.type}"
  instance_ami  = "${local.ec2.ami}"
  tags          = "${local.tags}"
}