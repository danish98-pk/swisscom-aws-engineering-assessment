resource "aws_lambda_function" "starter_lambda" {
  filename         = "starter_lambda.zip"
  function_name    = "starter_lambda"
  handler          = "starter_lambda.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.starter_lambda_role.arn
  source_code_hash = filebase64sha256("starter_lambda.zip")
  timeout = 900 

  environment {
    variables = {
      STEP_FUNCTION_ARN = aws_sfn_state_machine.file_workflow.arn
    }
  }
}

resource "aws_lambda_function" "write_metadata" {
  filename         = "write_metadata_lambda.zip"
  function_name    = "write_metadata"
  handler          = "write_metadata_lambda.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.worker_lambda_role.arn
  source_code_hash = filebase64sha256("write_metadata_lambda.zip")
  timeout = 900 
}



