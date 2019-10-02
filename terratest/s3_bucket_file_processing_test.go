package test

import (
	"fmt"
	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS3BucketProcessing(t *testing.T) {
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
	region := terraform.Output(t, terraformOptions, "region")
	bucketName := terraform.Output(t, terraformOptions, "bucket_name")

	// 1. Read content of 'file.txt'
	key := "file.txt"

	file, err := os.Open(key)
	if err != nil {
		t.Fatal("Failed to open file")
	}

	// 2. Upload file 'file.txt' to S3.
	uploadFileToS3(t, region, bucketName, key, file)

	// 3. Wait for processed object and validate content
	processedObjectKey := fmt.Sprintf("new_%s", key)

	maxRetries := 50
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("Wait for processed file %s", processedObjectKey)

	actualObjectContent := retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		objectContent, err := aws.GetS3ObjectContentsE(t, region, bucketName, processedObjectKey)

		if err != nil {
			return "", err
		}

		return objectContent, nil
	})

	expectedObjectContent := "Hello, World!"
	assert.Equal(t, expectedObjectContent, actualObjectContent)
}

func uploadFileToS3(t *testing.T, region string, bucketName string, key string, file *os.File) {
	uploader := aws.NewS3Uploader(t, region)

	result, err := uploader.Upload(&s3manager.UploadInput{
		Bucket: awssdk.String(bucketName),
		Key:    awssdk.String(key),
		Body:   file,
	})

	if err != nil {
		t.Fatal("Failed to upload file to S3")
	}

	fmt.Printf("File uploaded to, %s\n", result.Location)
}
