""" This function reads created object on S3 Bucket and creates new object with prefix 'new_'
adding ' World' to the end of the file content

On object created event:
filename: test.txt -> new_test.txt
content: Hello -> Hello World
"""
import json
import boto3
import logging

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

S3 = boto3.client('s3')

def handler(event, context):
    bucket_name = event["Records"][0]["s3"]["bucket"]["name"]
    received_object_key = event["Records"][0]["s3"]["object"]["key"]

    LOGGER.info(f"REQUEST RAW: {json.dumps(event)}")

    if "new" not in received_object_key:
        received_object = S3.get_object(
            Bucket=bucket_name,
            Key=received_object_key
        )
        received_object_content = received_object['Body'].read().decode('utf-8')
        process_object(received_object_content, received_object_key, bucket_name)


def process_object(received_object_content, received_object_key, bucket_name):
    new_object_content = f"{received_object_content}, World!"
    new_object_key = f"new_{received_object_key}"

    S3.put_object(
        Bucket=bucket_name,
        Key=new_object_key,
        Body=new_object_content,
        ContentType='text/html'
    )