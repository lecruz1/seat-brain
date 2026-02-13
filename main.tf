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
    bucket = "hella-seat-brains-reports-leonardo-arroyo"
    key    = "terraform/state"
    region = "us-east-2"
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. El Bucket (Asegúrate de que el nombre interno sea seat_release_bucket)
resource "aws_s3_bucket" "seat_release_bucket" {
  bucket = var.bucket_name
}

# 2. El Lifecycle (Cámbialo para que use seat_release_bucket)
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

# 3. La seguridad (Asegúrate de que también use seat_release_bucket)
resource "aws_s3_bucket_public_access_block" "security_policy" {
  bucket = aws_s3_bucket.seat_release_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}