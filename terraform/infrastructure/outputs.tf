output "instance_url" {
  value = "http://${module.web_server.ec2_url}:8080"
}