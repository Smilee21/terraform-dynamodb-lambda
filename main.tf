# Proveedor AWS
provider "aws" {
  region = "us-west-2" 
}

# Recurso: Tabla DynamoDB
resource "aws_dynamodb_table" "prompt_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "prompt_id"

  attribute {
    name = "prompt_id"
    type = "S"
  }

   attribute {
    name = "content"
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

# Recurso: Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"                     
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = "${path.module}/lambda/function.zip" 

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.prompt_table.name 
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Output: Nombre de la tabla DynamoDB
output "dynamodb_table_name" {
  value = aws_dynamodb_table.prompt_table.name # Usamos el nombre actualizado
}

# Output: ARN de la función Lambda
output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}
