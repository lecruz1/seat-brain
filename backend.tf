terraform {
  required_version = ">= 1.0.0"

  # 1. Bloque de proveedores requeridos agregado
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Bloqueamos la versión mayor para evitar sorpresas
    }
  }

  # 2. Backend S3 completo con seguridad y candado
  backend "s3" {
    bucket         = "seat-brain-tf-state-leonardo-arroyo"
    key            = "project/seat-brain/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "seat-brain-terraform-locks" # <- El candado contra el ConditionalCheckFailed
    encrypt        = true                         # <- Datos encriptados y seguros
  }
}

provider "aws" {
  region = "us-east-2"
}