#test_write_metadata_lambda.py
# refernce:  https://realpython.com/python-mock-library/

import unittest
from unittest.mock import patch, MagicMock
import write_metadata_lambda

class TestMetadataLambda(unittest.TestCase):

    @patch('write_metadata_lambda.dynamodb')  # mock the DynamoDB resource
    def test_lambda_handler_success(self, mock_dynamodb):
        # Mock the table object and its put_item method
        mock_table = MagicMock()
        mock_dynamodb.Table.return_value = mock_table

        # Fake event passed to Lambda
        event = {
            "bucket_name": "my-test-bucket",
            "file_key": "testfile.txt"
        }

        # Run the Lambda
        response = write_metadata_lambda.lambda_handler(event, None)

        # Assert that DynamoDB Table was called with correct name
        mock_dynamodb.Table.assert_called_with("file-metadata")

        # Assert put_item was called once
        mock_table.put_item.assert_called_once()
        args, kwargs = mock_table.put_item.call_args
        item = kwargs["Item"]

        # Check that filename matches event
        self.assertEqual(item["Filename"], "testfile.txt")

        # Check Lambda response status
        self.assertEqual(response["status"], "success")
        self.assertEqual(response["Filename"], "testfile.txt")

        # Ensure UploadTimestamp exists and looks like ISO format (yyyy-mm-ddTHH:mm:ss)
        self.assertIn("T", response["UploadTimestamp"])

if __name__ == "__main__":
    unittest.main()














