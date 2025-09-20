# test_starter_lambda.py
# https://realpython.com/python-mock-library/

import unittest
from unittest.mock import patch, MagicMock
import starter_lambda

class TestLambdaHandler(unittest.TestCase):

    @patch.dict('os.environ', {'STEP_FUNCTION_ARN': 'arn:aws:states:eu-central-1:123456789012:stateMachine:myStateMachine'})
    @patch('starter_lambda.sf_client')  # patch the actual sf_client in starter_lambda
    def test_lambda_handler_success(self, mock_sf_client):
        
        # Mock the start_execution response
        mock_sf_client.start_execution.return_value = {
            'executionArn': 'arn:aws:states:eu-central-1:123456789012:execution:myStateMachine:execution123',
            'startDate': MagicMock(isoformat=lambda: '2025-09-20T12:00:00')
        }

        # Mock S3 event
        event = {
            'Records': [{
                's3': {
                    'bucket': {'name': 'my-bucket'},
                    'object': {'key': 'test%20file.txt'}
                }
            }]
        }

        response = starter_lambda.lambda_handler(event, None)

        # Assert Step Function was called correctly
        mock_sf_client.start_execution.assert_called_once()
        self.assertEqual(response['executionArn'], 'arn:aws:states:eu-central-1:123456789012:execution:myStateMachine:execution123')
        self.assertEqual(response['startDate'], '2025-09-20T12:00:00')

if __name__ == '__main__':
    unittest.main()
