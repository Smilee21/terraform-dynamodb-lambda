# Recurso: Cognito Identity Pool
resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "${var.environment}-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.user_pool_client.id
    provider_name = aws_cognito_user_pool.user_pool.endpoint
  }
}

# Recurso: IAM Role para usuarios autenticados
resource "aws_iam_role" "authenticated_role" {
  name               = "${var.environment}-authenticated-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Federated = "cognito-identity.amazonaws.com" },
        Action    = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.identity_pool.id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "authenticated_policy" {
  name        = "${var.environment}-authenticated-policy"
  description = "Policy for authenticated users to invoke Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "lambda:InvokeFunction",
        Resource = aws_lambda_function.my_lambda.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "authenticated_policy_attachment" {
  role       = aws_iam_role.authenticated_role.name
  policy_arn = aws_iam_policy.authenticated_policy.arn
}

# Recurso: Vinculación de roles con Identity Pool
resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    authenticated = aws_iam_role.authenticated_role.arn
  }
}

# Recurso: User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.environment}-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  tags = {
    Environment = var.environment
  }
}

# Recurso: User Pool Client
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "${var.environment}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"  
  ]
}

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

# Recurso: Política Bedrock Invoke
resource "aws_iam_role_policy" "bedrock_invoke_policy" {
  name = "${var.environment}-bedrock-invoke-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "bedrock:InvokeModel",
        Resource = "*"
      }
    ]
  })
}

# Consolidación de políticas para el rol de Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
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
  timeout = 60 

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.prompt_table.name
    }
  }

  tags = {
    Environment = var.environment
  }
}
