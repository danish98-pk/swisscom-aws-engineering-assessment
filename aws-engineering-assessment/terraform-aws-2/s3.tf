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

# Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "uploads_lifecycle" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    # Required filter (empty = entire bucket)
    filter {}

    expiration {
      days = 90
    }
  }
}
