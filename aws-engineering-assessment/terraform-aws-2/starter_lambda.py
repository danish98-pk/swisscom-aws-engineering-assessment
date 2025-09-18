# import json
# import urllib.parse
# import boto3
# import os

# STEP_FUNCTION_ARN = os.environ['STEP_FUNCTION_ARN']
# sf_client = boto3.client('stepfunctions')

# def lambda_handler(event, context):
#     try:
#         record = event['Records'][0]
#         bucket_name = record['s3']['bucket']['name']
#         file_key = urllib.parse.unquote_plus(record['s3']['object']['key'])

#         input_payload = {
#             'bucket_name': bucket_name,
#             'file_key': file_key
#         }

#         response = sf_client.start_execution(
#             stateMachineArn=STEP_FUNCTION_ARN,
#             input=json.dumps(input_payload)
#         )
#         print("Step Function started:", response['executionArn'])
#         return response

#     except Exception as e:
#         print("Error starting Step Function:", e)
#         raise e

import json
import urllib.parse
import boto3
import os

STEP_FUNCTION_ARN = os.environ['STEP_FUNCTION_ARN']
sf_client = boto3.client('stepfunctions')

def lambda_handler(event, context):
    try:
        record = event['Records'][0]
        bucket_name = record['s3']['bucket']['name']
        file_key = urllib.parse.unquote_plus(record['s3']['object']['key'])

        input_payload = {
            'bucket_name': bucket_name,
            'file_key': file_key
        }

        response = sf_client.start_execution(
            stateMachineArn=STEP_FUNCTION_ARN,
            input=json.dumps(input_payload)
        )

        # Convert startDate (datetime) to ISO string
        safe_response = {
            'executionArn': response['executionArn'],
            'startDate': response['startDate'].isoformat()
        }

        print("Step Function started:", safe_response['executionArn'])
        return safe_response

    except Exception as e:
        print("Error starting Step Function:", e)
        raise e
