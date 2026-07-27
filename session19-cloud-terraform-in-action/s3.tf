resource "random_id" "s3_suffix" {
  byte_length = 4
}

# S3 Bucket for App Assets & Artifacts
resource "aws_s3_bucket" "app_storage" {
  bucket = "cloud-iac-${var.environment}-${random_id.s3_suffix.hex}"

  tags = {
    Name = "${var.environment}-app-storage"
  }
}

resource "aws_s3_bucket_versioning" "storage_versioning" {
  bucket = aws_s3_bucket.app_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "storage_block" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
