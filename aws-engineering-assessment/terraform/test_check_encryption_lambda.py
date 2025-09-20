# # test_check_encryption_lambda.py
# # Similar structure to test_starter_lambda.py

# import unittest
# from unittest.mock import patch, MagicMock
# import check_encryption_lambda



# class TestCheckEncryptionLambda(unittest.TestCase):

#     @patch('check_encryption_lambda.sns_client')
#     @patch('check_encryption_lambda.ddb_client')
#     @patch('check_encryption_lambda.s3_client')
#     def test_unencrypted_resources(self, mock_s3_client, mock_ddb_client, mock_sns_client):
#         # Mock S3: one bucket with no encryption
#         mock_s3_client.list_buckets.return_value = {'Buckets': [{'Name': 'unencrypted-bucket'}]}
#         mock_s3_client.get_bucket_encryption.side_effect = mock_s3_client.exceptions.ClientError(
#             {"Error": {"Code": "ServerSideEncryptionConfigurationNotFoundError"}}, "GetBucketEncryption"
#         )

#         # Mock DynamoDB: one table with no SSEDescription
#         mock_ddb_client.list_tables.return_value = {'TableNames': ['unencrypted-table']}
#         mock_ddb_client.describe_table.return_value = {'Table': {'TableName': 'unencrypted-table'}}

#         # Mock SNS publish
#         mock_sns_client.publish.return_value = {"MessageId": "123"}

#         # Run Lambda
#         response = check_encryption_lambda.lambda_handler({}, None)

#         # Assertions
#         mock_sns_client.publish.assert_called_once()
#         self.assertEqual(response["status"], "Alert sent")
#         self.assertIn("S3 Bucket 'unencrypted-bucket' is unencrypted", response["details"])
#         self.assertIn("DynamoDB Table 'unencrypted-table' is unencrypted", response["details"])

#     @patch.dict('os.environ', {'SNS_TOPIC_ARN': 'arn:aws:sns:eu-central-1:123456789012:security-alerts'})
#     @patch('check_encryption_lambda.sns_client')
#     @patch('check_encryption_lambda.ddb_client')
#     @patch('check_encryption_lambda.s3_client')
#     def test_all_encrypted(self, mock_s3_client, mock_ddb_client, mock_sns_client):
#         # Mock S3: encrypted bucket
#         mock_s3_client.list_buckets.return_value = {'Buckets': [{'Name': 'encrypted-bucket'}]}
#         mock_s3_client.get_bucket_encryption.return_value = {"ServerSideEncryptionConfiguration": {}}

#         # Mock DynamoDB: encrypted table
#         mock_ddb_client.list_tables.return_value = {'TableNames': ['encrypted-table']}
#         mock_ddb_client.describe_table.return_value = {
#             'Table': {'TableName': 'encrypted-table', 'SSEDescription': {'Status': 'ENABLED'}}
#         }

#         # Run Lambda
#         response = check_encryption_lambda.lambda_handler({}, None)

#         # Assertions
#         mock_sns_client.publish.assert_not_called()
#         self.assertEqual(response["status"], "All resources encrypted")


# if __name__ == '__main__':
#     unittest.main()


### eventually i have to move the os env under the module to import THE SNSTOPIC ARN from the main lambda using @patch.dict
import os
import unittest
from unittest.mock import patch, MagicMock
from botocore.exceptions import ClientError

# Set environment variable before importing Lambda
os.environ['SNS_TOPIC_ARN'] = 'arn:aws:sns:eu-central-1:123456789012:security-alerts'

import check_encryption_lambda


class TestCheckEncryptionLambda(unittest.TestCase):

    @patch('check_encryption_lambda.sns_client')
    @patch('check_encryption_lambda.ddb_client')
    @patch('check_encryption_lambda.s3_client')
    def test_unencrypted_resources(self, mock_s3, mock_ddb, mock_sns):
        # Patch the exceptions attribute of the mock to include ClientError
        mock_s3.exceptions = MagicMock()
        mock_s3.exceptions.ClientError = ClientError

        # Mock S3: unencrypted bucket
        mock_s3.list_buckets.return_value = {'Buckets': [{'Name': 'unencrypted-bucket'}]}
        mock_s3.get_bucket_encryption.side_effect = ClientError(
            {"Error": {"Code": "ServerSideEncryptionConfigurationNotFoundError"}}, "GetBucketEncryption"
        )

        # Mock DynamoDB: unencrypted table
        mock_ddb.list_tables.return_value = {'TableNames': ['unencrypted-table']}
        mock_ddb.describe_table.return_value = {'Table': {'TableName': 'unencrypted-table'}}

        # Mock SNS publish
        mock_sns.publish.return_value = {"MessageId": "123"}

        # Run Lambda
        response = check_encryption_lambda.lambda_handler({}, None)

        # Assertions
        self.assertEqual(response['status'], "Alert sent")
        self.assertIn("S3 Bucket 'unencrypted-bucket' is unencrypted", response['details'])
        self.assertIn("DynamoDB Table 'unencrypted-table' is unencrypted", response['details'])
        mock_sns.publish.assert_called_once()

    @patch('check_encryption_lambda.sns_client')
    @patch('check_encryption_lambda.ddb_client')
    @patch('check_encryption_lambda.s3_client')
    def test_all_encrypted(self, mock_s3, mock_ddb, mock_sns):
        # Mock S3: encrypted bucket
        mock_s3.list_buckets.return_value = {'Buckets': [{'Name': 'encrypted-bucket'}]}
        mock_s3.get_bucket_encryption.return_value = {"ServerSideEncryptionConfiguration": {}}

        # Mock DynamoDB: encrypted table
        mock_ddb.list_tables.return_value = {'TableNames': ['encrypted-table']}
        mock_ddb.describe_table.return_value = {
            'Table': {'TableName': 'encrypted-table', 'SSEDescription': {'Status': 'ENABLED'}}
        }

        # Run Lambda
        response = check_encryption_lambda.lambda_handler({}, None)

        # Assertions
        self.assertEqual(response['status'], "All resources encrypted")
        mock_sns.publish.assert_not_called()


if __name__ == '__main__':
    unittest.main()
