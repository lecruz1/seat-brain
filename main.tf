# 1. Definicion del proveedor y Backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ESTO ES LO QUE CONECTA CON GITHUB ACTIONS
  backend "s3" {
    bucket         = "hella-seat-brains-reports-leonardo-arroyo"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "seat_release_bucket" {
  bucket = var.bucket_name
}

# 2. El Lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "cleanup_reports" {
  bucket = aws_s3_bucket.seat_release_bucket.id

  rule {
    id     = "auto-delete-old-reports"
    status = "Enabled"

    filter {}

    expiration {
      days = 7
    }
  }
}

# 3. La seguridad 
resource "aws_s3_bucket_public_access_block" "security_policy" {
  bucket = aws_s3_bucket.seat_release_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

import {
  to = aws_s3_bucket.seat_release_bucket
  id = "hella-seat-brains-reports-leonardo-arroyo"
}

import {
  to = aws_dynamodb_table.terraform_locks
  id = "terraform-state-locking"
}