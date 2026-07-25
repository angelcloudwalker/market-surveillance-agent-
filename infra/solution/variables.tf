variable "aws_region" {
  default = "us-east-2"
}

variable "db_username" {
  description = "Usuario master RDS"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password master RDS"
  type        = string
  sensitive   = true
}
