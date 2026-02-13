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

resource "aws_s3_bucket" "reports_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "Reports Bucket"
    Environment = var.environment
  }
}

# 3. Bloqueo del acceso público por seguridad (Referenciado correctamente)
resource "aws_s3_bucket_public_access_block" "security_policy" {
  bucket = aws_s3_bucket.seat_release_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "cleanup_reports" {
  bucket = aws_s3_bucket.reports_bucket.id

  rule {
    id     = "auto-delete-old-reports"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}