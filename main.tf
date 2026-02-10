# 1. Definicion del proveedor (aws)
terraform{
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
    region = "us-east-2"
}

# 2. Creacion del bucket para los reportes de asiento
resource "aws_s3_bucket" "seat_release_bucket_arrole1" {
  # Recordatorio: los nombres de los buckets deben ser unicos en todo el mundo
  bucket = "hella-seat-brains-reports-leonardo-arroyo"

  tags = {
    Name        = "Seat Brain Reports"
    Environment = "DevOps training"
  }
}

# Bloqueo del acceso público por seguridad
resource "aws_s3_bucket" "seat_release_bucket" {
  bucket = "tu-nombre-unico-aqui" 
}

resource "aws_s3_bucket_public_access_block" "security_policy" {

  bucket = aws_s3_bucket.seat_release_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}