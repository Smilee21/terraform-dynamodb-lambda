# Recurso: Bucket S3 para la aplicación React
module "prefix" {
  source = "../prefix"
}

# Creación del bucket
resource "aws_s3_bucket" "react_app_bucket" {
  bucket = "${module.prefix.generated_prefix}-react-app-bucket"
}

# Política para habilitar acceso público de lectura
resource "aws_s3_bucket_policy" "react_app_bucket_policy" {
  bucket = aws_s3_bucket.react_app_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.react_app_bucket.bucket}/*"
    }
  ]
}
POLICY
}

# Configuración para el sitio web estático
resource "aws_s3_bucket_website_configuration" "react_app_website" {
  bucket = aws_s3_bucket.react_app_bucket.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "react_app_public_access_block" {
  bucket = aws_s3_bucket.react_app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configuración CORS para el bucket S3
resource "aws_s3_bucket_cors_configuration" "cors_config" {
  bucket = aws_s3_bucket.react_app_bucket.bucket

  cors_rule {
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }
}

# Subir archivos del build de React a S3
resource "aws_s3_object" "react_build_files" {
  for_each = fileset("${path.module}/../frontend/dist", "**/*")


  bucket = aws_s3_bucket.react_app_bucket.bucket
  key    = each.value
  source = "${path.module}/../frontend/dist/${each.value}"
}


# Declarar la variable de región
variable "region" {
  description = "The AWS region to deploy the React app"
  type        = string
  default     = "us-east-1"
}


# Salida: URL del sitio estático de la aplicación React
output "react_app_static_site_url" {
  value       = "http://${aws_s3_bucket.react_app_bucket.bucket}.s3-website-${var.region}.amazonaws.com"
  description = "The URL for the React app's static site hosted on S3"
}
