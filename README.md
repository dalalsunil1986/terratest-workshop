# 1 | Amazon EC2 Web Server

This example deploys an EC2 Instance. 
To keep this example simple, we specify a User Data script that, while the server is 
booting, fires up a dirt-simple web server that returns “Hello, World” on port 8080.

## Terraform

### Terraform infrastructure diagram
![Diagram](diagrams/main.svg)

### Running this module manually

1. Install [Terraform](https://www.terraform.io/) (requires version >= 0.12.0) and make sure it's on your `PATH`.
1. Run `terraform init`.
1. Run `terraform apply`.
1. When you're done, run `terraform destroy`.

## Terratest

### Terratest infrastructure diagram
![Diagram](diagrams/test.svg)

### Running automated tests against this module

1. Install [Terraform](https://www.terraform.io/) (requires version >= 0.12.0) and make sure it's on your `PATH`.
1. Install [Golang](https://golang.org/) (requires version >=1.10) and make sure this code is checked out into your `GOPATH`.
1. Install [Dep](https://github.com/golang/dep) (requires version >=0.5.1)
1. Go to `terratest` directory
1. `dep ensure`
1. `go test`

## Next example

`git checkout step2`