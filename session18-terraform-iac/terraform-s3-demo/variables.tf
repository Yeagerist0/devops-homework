variable "aws_region" {
  description = "The AWS Region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  description = "Prefix for the globally unique S3 bucket name"
  type        = string
  default     = "hitarth-devops-s3"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}
