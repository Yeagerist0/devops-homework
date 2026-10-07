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
}

variable "aws_region" {
  default = "us-east-1"
}

resource "aws_vpc" "final_vpc" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name    = "final-devops-vpc"
    Student = "Hitarth Jain"
  }
}

resource "aws_subnet" "final_subnet" {
  vpc_id            = aws_vpc.final_vpc.id
  cidr_block        = "10.100.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "final-devops-subnet"
  }
}

output "vpc_id" {
  value = aws_vpc.final_vpc.id
}
