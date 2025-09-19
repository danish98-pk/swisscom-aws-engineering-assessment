#!/bin/bash
set -euo pipefail

ENDPOINT="http://localhost:4566"
REGION="eu-central-1"
TABLE_NAME="file-metadata"

echo "Checking if DynamoDB table '$TABLE_NAME' exists in LocalStack"

if aws --endpoint-url=$ENDPOINT dynamodb describe-table \
   --region $REGION \
   --table-name $TABLE_NAME >/dev/null 2>&1; then
    echo "Table exists. Deleting..."
    aws --endpoint-url=$ENDPOINT dynamodb delete-table \
        --region $REGION \
        --table-name $TABLE_NAME

    echo "Waiting for table deletion to complete..."
    aws --endpoint-url=$ENDPOINT dynamodb wait table-not-exists \
        --region $REGION \
        --table-name $TABLE_NAME
    echo "Table '$TABLE_NAME' deleted successfully."
else
    echo "Table '$TABLE_NAME' does not exist. Nothing to delete."
fi
