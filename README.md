# Terratest workshop
This repository contains materials for use in a [Terratest](https://github.com/gruntwork-io/terratest) workshop.

## About

The following branches contains some simple examples of [Terraform](https://www.terraform.io/) infrastructure code with 
automated tests created with [Terratest](https://github.com/gruntwork-io/terratest).

| Example name                                                                                                   | Branch               |
|----------------------------------------------------------------------------------------------------------------|----------------------|
| [Amazon EC2 Web Server  ](https://github.com/rmitula/terratest-workshop/tree/step1)                            | `git checkout step1` |
| [S3 Bucket file processing](https://github.com/rmitula/terratest-workshop/tree/step2)                          | `git checkout step2` |
| [RESTful shopping cart - Saving order to DynamoDB](https://github.com/rmitula/terratest-workshop/tree/step3)   | `git checkout step3` |
| [RESTful shopping cart - Sending order notification](https://github.com/rmitula/terratest-workshop/tree/step4) | `git checkout step4` |

## Requirements

1. Install [Terraform](https://www.terraform.io/) (requires version >= 0.12.0). and make sure it's on your `PATH`.
1. Install [Golang](https://golang.org/) (requires version >=1.10) and make sure this code is checked out into your 
`GOPATH` (you can check `GOPATH` directory with `go env`).
1. Install [Dep](https://github.com/golang/dep) (requires version >=0.5.1).
