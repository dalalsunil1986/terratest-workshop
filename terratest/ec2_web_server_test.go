package test

import (
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestWebServer(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../terraform/infrastructure",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"owner": random.UniqueId(),
			"env":   "TEST",
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	instanceURL := terraform.Output(t, terraformOptions, "instance_url")

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second

	expectedResponse := "Hello, World!"

	// Verify that we get back a 200 OK with the expected instanceText
	http_helper.HttpGetWithRetry(t, instanceURL, nil, 200, expectedResponse, maxRetries, timeBetweenRetries)
}
