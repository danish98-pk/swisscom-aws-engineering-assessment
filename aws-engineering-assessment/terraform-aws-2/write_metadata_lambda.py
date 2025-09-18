import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = "file-metadata"

def lambda_handler(event, context):
    bucket = event['bucket_name']
    key = event['file_key']

    # Current timestamp as string
    upload_time = datetime.utcnow().isoformat()

    table = dynamodb.Table(TABLE_NAME)
    table.put_item(
        Item={
            "Filename": key,
            "UploadTimestamp": upload_time
        }
    )
    print(f"Metadata written for file {key} in bucket {bucket}")

    return {
        "status": "success",
        "Filename": key,
        "UploadTimestamp": upload_time  # Must be string, not datetime
    }
