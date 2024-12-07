variable "dynamodb_table_name" {
  description = "El nombre de la tabla DynamoDB"
  type        = string
  default     = "prompt_table" 
}

variable "lambda_function_name" {
  description = "El nombre de la función Lambda"
  type        = string
  default     = "myLambdaFunction" 
}

variable "environment" {
  description = "El entorno en el que se ejecuta la infraestructura"
  type        = string
  default     = "dev"  
}

variable "build_path" {
  description = "Ruta donde se encuentran los archivos de build de React"
  type        = string
  default     = "build"
}
 