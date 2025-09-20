data "aws_caller_identity" "current" {}


# Generate a random suffix to make bucket name unique
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# KMS key for S3 bucket encryption
resource "aws_kms_key" "s3_key" {
  description = "KMS key for S3 bucket encryption"
}

# S3 bucket
resource "aws_s3_bucket" "uploads" {
  bucket = "file-upload-bucket-${random_id.bucket_suffix.hex}"
}

# Server-side encryption using KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "uploads_sse" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.id
    }

  }
}


# Null resource to apply lifecycle configuration via AWS CLI { Somehow the LocalStack is not liking lifecycle configuration resource type block , we have to do it another way by using aws cli command}
resource "null_resource" "s3_lifecycle" {
  depends_on = [aws_s3_bucket.uploads]

  provisioner "local-exec" {
    command = "aws --endpoint-url=http://localhost:4566 s3api put-bucket-lifecycle-configuration --bucket ${aws_s3_bucket.uploads.id} --lifecycle-configuration '{\"Rules\":[{\"ID\":\"expire-old-objects\",\"Status\":\"Enabled\",\"Filter\":{},\"Expiration\":{\"Days\":90}}]}'"
  }
}
