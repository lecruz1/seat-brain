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

# 1. Declaración del Bucket
resource "aws_s3_bucket" "reports_bucket" {  # <--- Este es el nombre interno
  bucket = var.bucket_name
}

# 2. Bloqueo de acceso público (Ajusta el nombre aquí)
resource "aws_s3_bucket_lifecycle_configuration" "cleanup_reports" {
  bucket = aws_s3_bucket.reports_bucket.id

  rule {
    id     = "auto-delete-old-reports"
    status = "Enabled"

    filter {}  # <--- AGREGA ESTO para que aplique a todo el bucket

    expiration {
      days = 7
    }
  }
}