variable "region" {
  default = "eu-central-1"


}

variable "bucket_name" {
  default = "file-upload-bucket"
}

variable "dynamodb_table" {
  default = "Files"
}

variable "lambda_name" {
  default = "file-processor-lambda"
}

variable "sns_topic_name" {
  default = "security-alerts"
}

variable "step_function_name" {
  default = "file-upload-workflow"
}


