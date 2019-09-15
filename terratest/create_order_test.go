package test

import (
	"errors"
	"fmt"
	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestCreateOrder(t *testing.T) {
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
	tableName := terraform.Output(t, terraformOptions, "db_table_name")
	apiGatewayUrl := terraform.Output(t, terraformOptions, "api_gateway_url")

	maxRetries := 20
	timeBetweenRetries := 5 * time.Second

	// 1. Send POST request to Amazon API Gateway
	itemName := "Sample Item Name"
	json := fmt.Sprintf(`{"item":"%s"}`, itemName)
	body := []byte(json)

	headers := make(map[string]string)
	headers["Content-Type"] = "application/json"

	http_helper.HTTPDoWithRetry(t, "POST", apiGatewayUrl, body, headers, 200, maxRetries, timeBetweenRetries)

	// 2. Check if new specified record was created in Amazon DynamoDB table
	description := fmt.Sprintf("Wait until DynamoDB object will be found\n")

	databaseItemName := retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		result := getItemFromDynamoDb(t, region, tableName, itemName)

		type DatabaseItem struct {
			Id     string
			Item   string
			Date   string
			Status string
		}

		databaseItem := DatabaseItem{}

		err := dynamodbattribute.UnmarshalMap(result.Item, &databaseItem)
		if err != nil {
			t.Fatal(fmt.Sprintf("Failed to unmarshal Record, %v\n", err))
		}

		if databaseItem.Item == "" {
			return "", errors.New(fmt.Sprintf("specified item (%s) does not exist in DynamoDB table", itemName))
		}

		fmt.Printf("Got item from DynamoDB table, %s\n", result)
		return databaseItem.Item, nil
	})

	assert.Equal(t, itemName, databaseItemName)
}

func getItemFromDynamoDb(t *testing.T, region string, tableName string, itemName string) *dynamodb.GetItemOutput {
	dynamoDbClient := aws.NewDynamoDBClient(t, region)

	result, err := dynamoDbClient.GetItem(&dynamodb.GetItemInput{
		TableName: awssdk.String(tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"Item": {
				S: awssdk.String(itemName),
			},
		},
	})

	if err != nil {
		t.Fatal("Failed to get item from DynamoDB table\n", err)
	}

	return result
}
