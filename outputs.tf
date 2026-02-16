# El nombre exacto del bucket
output "bucket_name" {
  description = "Nombre del bucket de S3"
  value       = aws_s3_bucket.seat_release_bucket.id
}

# El ARN (Amazon Resource Name)
output "bucket_arn" {
  description = "ARN del bucket"
  value       = aws_s3_bucket.seat_release_bucket.arn
}

# El Domain Name (útil para integraciones o CDN)
output "bucket_domain_name" {
  description = "URL del dominio del bucket"
  value       = aws_s3_bucket.seat_release_bucket.bucket_regional_domain_name
}

# Nombre de la función Lambda (para saber que se desplegó bien)
output "lambda_function_name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.reports_lambda.function_name
}