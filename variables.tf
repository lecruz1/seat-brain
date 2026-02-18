variable "aws_region" {
  description = "Región de AWS donde se desplegará la infra"
  type        = string
  default     = "us-east-2"
}

variable "bucket_name" {
  description = "Nombre único del bucket de reportes"
  type        = string
  default     = "hella-seat-brains-reports-leonardo-arroyo-v2"
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
  default     = "seat-incident-generator"
}

variable "python_runtime" {
  description = "Runtime de Python para la función Lambda"
  type        = string
  default     = "python3.9"
}