package test

import (
	"encoding/json"
	"fmt"
	awssdk "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/sns"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestSendOrderNotification(t *testing.T) {
	t.Parallel()

	terraformDirectory := "../terraform/infrastructure"

	/*
		STAGE: CLEANUP
		At the end of the test, run `terraform destroy` to clean up any resources that were created by terraform.

		1. Destroy created temporary queue
		2. Destroy terraform resources
	*/
	defer test_structure.RunTestStage(t, "CLEANUP", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, terraformDirectory)

		region := terraform.Output(t, terraformOptions, "region")
		temporaryQueueUrl := test_structure.LoadString(t, terraformDirectory, "temporary_queue_url")

		// 1. Destroy created temporary queue
		aws.DeleteQueue(t, region, temporaryQueueUrl)

		// 2. Destroy terraform resources
		terraform.Destroy(t, terraformOptions)
	})

	/*
		STAGE: APPLY
		Run `terraform init` and `terraform apply` and fail the test if there are any errors.

		1. Save terraform options & outputs so future test stages can use them
		2. Run terraform init & apply
		3. Save terraform outputs
	*/
	test_structure.RunTestStage(t, "APPLY", func() {
		terraformOptions := &terraform.Options{
			TerraformDir: terraformDirectory,

			Targets: []string{
				"module.compute",
				"module.database",
				"module.notification",
			},

			Vars: map[string]interface{}{
				"owner": random.UniqueId(),
				"env":   "TEST",
			},
		}

		// 1. Save terraform options so future test stages can use them
		test_structure.SaveTerraformOptions(t, terraformDirectory, terraformOptions)

		// 2. Run terraform init & apply
		terraform.InitAndApply(t, terraformOptions)

		// 3. Save terraform outputs
		region := terraform.Output(t, terraformOptions, "region")
		sqsQueueUrl := terraform.Output(t, terraformOptions, "sqs_queue_url")
		snsTopicArn := terraform.Output(t, terraformOptions, "sns_topic_arn")

		test_structure.SaveString(t, terraformDirectory, "region", region)
		test_structure.SaveString(t, terraformDirectory, "sqs_queue_url", sqsQueueUrl)
		test_structure.SaveString(t, terraformDirectory, "sns_topic_arn", snsTopicArn)
	})

	/*
		STAGE: SETUP
		Create SQS Queue subscribed to SNS Topic to receive notification

		1. Create temporary SQS Queue
		2. Subscribe temporary created queue with SNS notification topic
		3. Allow temporary queue to send messages
	*/
	test_structure.RunTestStage(t, "SETUP", func() {
		notificationSenderTopicArn := test_structure.LoadString(t, terraformDirectory, "sns_topic_arn")
		region := test_structure.LoadString(t, terraformDirectory, "region")

		sqsClient := aws.NewSqsClient(t, region)
		snsClient := aws.NewSnsClient(t, region)

		// 1. Create temporary SQS Queue
		queueName := fmt.Sprintf("%s-%s-TemporarySqsQueue", random.UniqueId(), "TEST")
		temporaryQueueUrl, sqsQueueAttributes := createSqsQueue(t, region, sqsClient, queueName)
		test_structure.SaveString(t, terraformDirectory, "temporary_queue_url", temporaryQueueUrl)

		// 2. Subscribe temporary created queue with SNS notification topic
		subscribeSqsQueueToSnsTopic(t, snsClient, sqsQueueAttributes, notificationSenderTopicArn)

		// 3. Allow temporary queue to send messages
		policy := PolicyDocument{
			Version: "2012-10-17",
			Statement: []StatementEntry{
				{
					Effect:    "Allow",
					Principal: "*",
					Action: []string{
						"sqs:SendMessage",
					},
					Resource: *sqsQueueAttributes.Attributes["QueueArn"],
				},
			},
		}

		addSqsQueuePolicy(t, sqsClient, temporaryQueueUrl, policy)
	})

	/*
		STAGE: TEST
		Run tests on created resources

		1. Send message to order queue
		2. Wait until notification message occur in temporary created queue
		3. Validate message content
	*/
	test_structure.RunTestStage(t, "TEST", func() {

		region := test_structure.LoadString(t, terraformDirectory, "region")
		createOrderQueueUrl := test_structure.LoadString(t, terraformDirectory, "sqs_queue_url")
		temporaryQueueUrl := test_structure.LoadString(t, terraformDirectory, "temporary_queue_url")

		itemName := "Sample Item Name"
		message := prepareQueueMessage(t, itemName)

		// 1. Send message to order queue
		aws.SendMessageToQueue(t, region, createOrderQueueUrl, message)

		// 2. Wait until notification message occur in temporary created queue
		queueResponse := aws.WaitForQueueMessage(t, region, temporaryQueueUrl, 200)
		if queueResponse.Error != nil {
			t.Fatal(queueResponse.Error)
		}

		logger.Logf(t, "Received message %s from temporary queue", queueResponse.MessageBody)

		temporaryQueueResponse := QueueResponse{}
		err := json.Unmarshal([]byte(queueResponse.MessageBody), &temporaryQueueResponse)
		if err != nil {
			t.Fatal(err)
		}

		// 3. Validate message content
		expectedQueueResponseMessage := fmt.Sprintf("New order has been created for: %s", itemName)
		assert.Equal(t, expectedQueueResponseMessage, temporaryQueueResponse.Message)
	})
}

func prepareQueueMessage(t *testing.T, itemName string) string {
	message := SqsMessage{
		SqsMessageBody: SqsMessageBody{
			Item: itemName,
		},
	}

	result, err := json.Marshal(message)
	if err != nil {
		t.Fatal(err)
	}
	return string(result)
}

func createSqsQueue(t *testing.T, region string, sqsClient *sqs.SQS, name string) (string, *sqs.GetQueueAttributesOutput) {
	temporaryQueueUrl := aws.CreateRandomQueue(t, region, name)
	result, err := sqsClient.GetQueueAttributes(&sqs.GetQueueAttributesInput{
		AttributeNames: []*string{
			awssdk.String("QueueArn"),
		},
		QueueUrl: awssdk.String(temporaryQueueUrl),
	})

	if err != nil {
		t.Fatal(err)
	}

	logger.Logf(t, "Successfully created queue %s", temporaryQueueUrl)

	return temporaryQueueUrl, result
}

func subscribeSqsQueueToSnsTopic(t *testing.T, snsClient *sns.SNS, sqsQueueAttributes *sqs.GetQueueAttributesOutput, topicArn string) {
	_, err := snsClient.Subscribe(&sns.SubscribeInput{
		Endpoint:              sqsQueueAttributes.Attributes["QueueArn"],
		Protocol:              awssdk.String("sqs"),
		ReturnSubscriptionArn: awssdk.Bool(true),
		TopicArn:              awssdk.String(topicArn),
	})

	if err != nil {
		t.Fatal(err)
	}

	logger.Logf(t, "Successfully subscribed to queue %s", topicArn)
}

func addSqsQueuePolicy(t *testing.T, sqsClient *sqs.SQS, sqsQueueUrl string, policy PolicyDocument) {
	jsonPolicy, err := json.Marshal(&policy)

	if err != nil {
		t.Fatal(err)
	}

	policyString := string(jsonPolicy)

	_, err = sqsClient.SetQueueAttributes(&sqs.SetQueueAttributesInput{
		QueueUrl: awssdk.String(sqsQueueUrl),
		Attributes: map[string]*string{
			"Policy": &policyString,
		},
	})

	if err != nil {
		t.Fatal(err)
	}

	logger.Logf(t, "Successfully added policy to queue %s", sqsQueueUrl)
}

type StatementEntry struct {
	Effect    string
	Principal string
	Action    []string
	Resource  string
}

type PolicyDocument struct {
	Version   string
	Statement []StatementEntry
}

type SqsMessageBody struct {
	Item string `json:"item"`
}

type SqsMessage struct {
	SqsMessageBody SqsMessageBody `json:"body"`
}

type QueueResponse struct {
	Type             string `json:"Type"`
	MessageID        string `json:"MessageId"`
	TopicArn         string `json:"TopicArn"`
	Subject          string `json:"Subject"`
	Message          string `json:"Message"`
	SignatureVersion string `json:"SignatureVersion"`
	Signature        string `json:"Signature"`
	SigningCertURL   string `json:"SigningCertURL"`
	UnsubscribeURL   string `json:"UnsubscribeURL"`
}
