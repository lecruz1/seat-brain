# Configuración del proveedor de AWS
provider "aws" {
  region = "us-east-2"
}

# Bucket de S3 para guardar el state
resource "aws_s3_bucket" "state_bucket" {
  bucket = "seat-brain-terraform-state"
  force_destroy = false #Evito borrar el bucket si tiene datos

  tags = {
    Environment = "bootstrap"
    Project = "seat-brain"
  }
}

# Tabla de DynamoDB para el state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name = "seat-brain-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  # Declaracion del tipo de dato para la llave LockID
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = "bootstrap"
    Project = "seat-brain"    
  }
}