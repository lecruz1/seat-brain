# 1. Definition of the provider and Backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # This connect to GITHUB Actions
  backend "s3" {
    bucket         = "hella-seat-brains-reports-leonardo-arroyo"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "seat_release_bucket" {
  bucket = var.bucket_name
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
data "archive_file" "lambda_zip"{
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda_function-zip"
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

# Lambda Function
resource "aws_lambda_function" "reports_lambda" {
  filename = data.archive_file.lambda_zip.output_path
  function_name = "seat-incident-generator"
  role = aws_iam_role.lambda_exec_role.arn
  handler = "lambda_function.lambda_handler" # Archivo.funcion
  runtime = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = ["arn:aws:lambda:us-east-2:336392948345:layer:AWSSDKPandas-Python39:20"]

  timeout     = 30   # Change the 3 seconds defect of AWS Lambda
  memory_size = 256  # Increase de RAM to 256 MB

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.seat_release_bucket.id
    }
  }
}