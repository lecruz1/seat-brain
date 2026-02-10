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
  region = "us-east-2"
}

# 2. Creacion del bucket (Usamos el nombre que ya creaste ayer)
resource "aws_s3_bucket" "seat_release_bucket" {
  bucket = "hella-seat-brains-reports-leonardo-arroyo"

  tags = {
    Name        = "Seat Brain Reports"
    Environment = "DevOps training"
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