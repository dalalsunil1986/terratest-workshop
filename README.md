# 3 | RESTful shopping cart - Saving order to DynamoDB

This example creates REST API architecture to process orders and save them in AWS DynamoDB table.

### How it works 

To create a new order we need to send HTTP POST message to Amazon API Gateway url:
```json
{
  "item" : "Sample Item Name"
}
```

The result is following record created in DynamoDB table:
```json
{
  "Date": "2019-09-13 16:29:14.025002",
  "Id": "77041b50-4ec7-4444-b42b-fceb0e1dc655",
  "Item": "Sample Item Name",
  "Status": "PENDING"
}
```

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

`git checkout step4`