# Starter Lambda Role
resource "aws_iam_role" "starter_lambda_role" {
  name = "starter_lambda_role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

#add stepfunction arn here
resource "aws_iam_role_policy" "starter_lambda_policy" {
  name = "starter_lambda_policy"
  role = aws_iam_role.starter_lambda_role.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: ["states:StartExecution"],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: ["logs:*"],
        Resource: "*"
      }
    ]
  })
}

# Worker Lambda Role (WriteMetadata) and (Time) - through StepFunction
resource "aws_iam_role" "worker_lambda_role" {
  name = "worker_lambda_role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "worker_lambda_policy" {
  name = "worker_lambda_policy"
  role = aws_iam_role.worker_lambda_role.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: ["dynamodb:PutItem", "dynamodb:DescribeTable"],
        Resource: "arn:aws:dynamodb:eu-central-1:000000000000:table/file-metadata"
      },
      {
        Effect: "Allow",
        Action: ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"],
        Resource: aws_kms_key.dynamodb_key.arn
      },
      {
        Effect: "Allow",
        Action: ["logs:*"],
        Resource: "*"
      }
    ]
  })
}



# IAM Role for check_encryption_lambda
resource "aws_iam_role" "check_encryption_lambda_role" {
  name = "check_encryption_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}


# IAM Policy for check_encryption_lambda
resource "aws_iam_role_policy" "check_encryption_lambda_policy" {
  name = "check_encryption_lambda_policy"
  role = aws_iam_role.check_encryption_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # S3 permissions
      {
        Effect   = "Allow",
        Action   = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketEncryption"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "000000000000"
          }
        }
      },

      # DynamoDB permissions
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:ListTables",
          "dynamodb:DescribeTable"
        ],
        Resource = "arn:aws:dynamodb:eu-central-1:000000000000:table/*",
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "000000000000"
          }
        }
      },

      # SNS publish to your topic only (already account-specific)
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = aws_sns_topic.alerts.arn
      },

      # CloudWatch Logs
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = "000000000000"
          }
        }
      }
    ]
  })
}
