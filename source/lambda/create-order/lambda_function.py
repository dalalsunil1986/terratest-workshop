""" This function inserts data in DynamoDB table
"""
import datetime
import logging
import boto3
import json
import uuid
import os

DB_TABLE_NAME = os.environ['DB_TABLE_NAME']
SNS_NOTIFICATION_TOPIC_ARN = os.environ["SNS_NOTIFICATION_TOPIC_ARN"]

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')


def handler(event, context):
    request_body = json.loads(event['Records'][0]['body'])
    request_item = request_body['body']['item']

    LOGGER.info(f"REQUEST RAW: {json.dumps(event)}")
    LOGGER.info(f"REQUEST BODY: {json.dumps(request_body)}")

    insert_data(request_item)
    send_notification(f"New order has been created for: {request_item}")


def insert_data(request_item):
    table = dynamodb.Table(DB_TABLE_NAME)

    response = table.put_item(
        Item = {
            'Id': str(uuid.uuid4()),
            'Item': request_item,
            'Date': str(datetime.datetime.utcnow()),
            'Status': 'PENDING'
        }
    )
    return response

def send_notification(message):
    sns.publish(
        TopicArn=SNS_NOTIFICATION_TOPIC_ARN,
        Message=message,
    )