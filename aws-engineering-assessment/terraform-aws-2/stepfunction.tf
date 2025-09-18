resource "aws_iam_role" "sfn_role" {
  name = "sfn_role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [{
      Effect    = "Allow",
      Principal = { Service = "states.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "sfn_policy" {
  name = "sfn_policy"
  role = aws_iam_role.sfn_role.id

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: ["lambda:InvokeFunction"],
        Resource: aws_lambda_function.write_metadata.arn
      }
    ]
  })
}


# resource "aws_sfn_state_machine" "file_workflow" {
#   name     = "FileUploadWorkflow"
#   role_arn = aws_iam_role.sfn_role.arn
#   definition = file("state_machine_definition.json")
# }


resource "aws_sfn_state_machine" "file_workflow" {
  name     = "FileUploadWorkflow"
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    Comment: "File metadata workflow",
    StartAt: "WriteMetadata",
    States: {
      WriteMetadata: {
        Type: "Task",
        Resource: aws_lambda_function.write_metadata.arn,
        End: true
      }
    }
  })
}
