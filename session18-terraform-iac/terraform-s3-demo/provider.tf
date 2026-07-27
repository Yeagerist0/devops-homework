terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DevOps-Homework"
      Student     = "Hitarth Jain"
      Enrollment  = "24BCS10399"
      Environment = var.environment
    }
  }
}
