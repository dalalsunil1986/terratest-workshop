resource "aws_instance" "web_server" {
  ami                    = "${var.instance_ami}"
  key_name               = "${aws_key_pair.web_server.key_name}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.web_server.id}"]

  connection {
    user        = "ec2-user"
    type        = "ssh"
    host        = "${aws_instance.web_server.public_ip}"
    private_key = "${tls_private_key.web_server.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello, World!' > index.html",
      "nohup python -m SimpleHTTPServer 8080 &",
      "sleep 1",
    ]
  }

  tags = "${var.tags}"
}

resource "aws_security_group" "web_server" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "web_server" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_server" {
  key_name   = "${var.instance_name}-KeyPair"
  public_key = "${tls_private_key.web_server.public_key_openssh}"
}