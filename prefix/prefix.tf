resource "random_id" "prefix" {
  byte_length = 4 
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "oliver-test"  
}

output "generated_prefix" {
  value = "${random_id.prefix.hex}-${var.project_name}"
}
