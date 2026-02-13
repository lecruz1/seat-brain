variable "aws_region" {
  description = "Región de AWS donde se desplegará la infra"
  type        = string
  default     = "us-east-2"
}

variable "bucket_name" {
  description = "Nombre único del bucket de reportes"
  type        = string
  default     = "hella-seat-brains-reports-leonardo-arroyo"
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}