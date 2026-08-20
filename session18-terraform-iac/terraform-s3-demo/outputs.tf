output "bucket_id" {
  description = "The globally unique name of the S3 bucket"
  value       = aws_s3_bucket.demo_bucket.id
}

output "bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the bucket"
  value       = aws_s3_bucket.demo_bucket.arn
}

output "bucket_region" {
  description = "The AWS Region where the bucket resides"
  value       = aws_s3_bucket.demo_bucket.region
}
