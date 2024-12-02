# Recurso: Tabla DynamoDB
resource "aws_dynamodb_table" "prompt_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "pk" 
  range_key      = "sk" 

  attribute {
    name = "pk" 
    type = "S"  
  }

  attribute {
    name = "sk"  
    type = "S" 
  }

  tags = {
    Environment = var.environment
  }
}

# Recurso: IAM Role para Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.lambda_function_name}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Adjuntar políticas con aws_iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Adjuntar política personalizada para Bedrock
resource "aws_iam_role_policy" "bedrock_invoke_policy" {
  name   = "BedrockInvokePolicy"
  role   = aws_iam_role.lambda_execution_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "bedrock:InvokeModel",
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0"
      }
    ]
  })
}

# Recurso: Null Resource para empaquetar las dependencias de Lambda (si existen)
resource "null_resource" "lambda_layer" {
  # Verificamos si el archivo requirements.txt tiene un hash para saber si tiene contenido
  triggers = {
    requirements = filesha1("${path.module}/lambda/requirements.txt")
  }

  # Solo intentamos instalar dependencias si requirements.txt tiene contenido
  provisioner "local-exec" {
    command = "python -m pip install -r ${path.module}/lambda/requirements.txt -t ${path.module}/layer/python"
  }
}

# Crear archivo .zip con las dependencias y el código de Lambda
data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"  # Empaquetamos todo el código Lambda
  output_path = "${path.module}/lambda/function.zip"

  depends_on = [null_resource.lambda_layer]  # Aseguramos que las dependencias se hayan instalado antes
  
  # Esta parte se asegura de que siempre empaquemos el código
}

# Recurso: Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"                     
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = data.archive_file.lambda_layer.output_path 

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.prompt_table.name 
    }
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [data.archive_file.lambda_layer]
}

# Output: Nombre de la tabla DynamoDB
output "dynamodb_table_name" {
  value = aws_dynamodb_table.prompt_table.name
}

# Output: ARN de la función Lambda
output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}
