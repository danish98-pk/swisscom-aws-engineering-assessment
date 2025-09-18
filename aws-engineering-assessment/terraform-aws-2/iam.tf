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
        Resource: aws_dynamodb_table.file_metadata.arn
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


