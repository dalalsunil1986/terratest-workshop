output "ec2_url" {
  value = "${aws_instance.web_server.public_ip}"
}