# 1. Definition of the provider and Backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # This connect to GITHUB Actions
  #backend "s3" {
    #bucket         = "hella-seat-brains-reports-leonardo-arroyo"
    #key            = "terraform.tfstate"
    #region         = "us-east-2"
    #dynamodb_table = "terraform-state-locking"
    #encrypt        = true
  #}
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "seat_release_bucket" {
  bucket = var.bucket_name
  
  tags = {
    Name        = "Seat Reports Bucket"
    Environment = var.environment
  }
}

# 2. Lifecycle
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

# 3. Security
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

#/import {
  #to = aws_s3_bucket.seat_release_bucket
  #id = "hella-seat-brains-reports-leonardo-arroyo"
#}

#import {
  #to = aws_dynamodb_table.terraform_locks
  #id = "terraform-state-locking"
#}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.seat_release_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Automatic ZIP creation
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda_function.zip"
}

# IAM role to Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "seat_reports_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

#Give permission to write on S3
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "seat_rports_s3_polic"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:GetObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.seat_release_bucket.arn}/*"
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda Function usando Container Image
resource "aws_lambda_function" "reports_lambda" {
  function_name = "${var.project_name}-${var.environment}" 
  role          = aws_iam_role.lambda_exec_role.arn
  
  # 1. Indicamos que usaremos una imagen de Docker
  package_type = "Image"
  
  # 2. Dirección de la imagen en ECR (usamos la URL del repositorio + el tag)
  image_uri    = "${aws_ecr_repository.seat_brain_repo.repository_url}:latest"

  # 3. Ajustes de capacidad (Pandas en Docker suele requerir un poco más de RAM)
  timeout     = 60 # Aumentamos a 60s por el tiempo de arranque del contenedor (Cold Start)
  memory_size = 512 # Recomendado para Pandas dentro de contenedores

  # 4. Variables de entorno (Se mantienen igual)
  environment {
    variables = {
      BUCKET_NAME   = aws_s3_bucket.seat_release_bucket.id
      ENV           = var.environment
      SNS_TOPIC_ARN = aws_sns_topic.incident_notifications.arn
    }
  }
}

# SNS topic creation
resource "aws_sns_topic" "incident_notifications" {
  name = "${var.project_name}-notifications"
}

# Email to recieve updates
resource "aws_sns_topic_subscription" "user_email_sub" {
  topic_arn = aws_sns_topic.incident_notifications.arn
  protocol  = "email"
  endpoint  = "leo_cruz19@hotmail.com"
}

# Permission for Lambda to publicy in my SNS
resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "${var.project_name}-sns-policy"
  description = "Permite a la Lambda enviar notificaciones a SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.incident_notifications.arn
      }
    ]
  })
}

# Lambda policy
resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

resource "aws_ecr_repository" "seat_brain_repo" {
  name                 = "seat-brain"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}