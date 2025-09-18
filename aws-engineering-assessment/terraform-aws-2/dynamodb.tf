resource "aws_kms_key" "dynamodb_key" {
  description = "KMS key for DynamoDB table"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "Allow root account full access"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::680343405290:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow Lambda role to use key"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.worker_lambda_role.arn }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "file_metadata" {
  name         = "file-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Filename"

  attribute {
    name = "Filename"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_key.arn
  }
}
