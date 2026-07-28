variable "aws_region" {
  default = "us-east-1"
}

variable "rds_endpoint" {
  description = "Endpoint de RDS — output del simulador"
  type        = string
}

variable "lambda_sg_id" {
  description = "SG de Lambdas — output del simulador"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "Subnets de la VPC default — output del simulador"
  type        = list(string)
}

variable "db_username" {
  description = "Usuario master de RDS"
  type        = string
}

variable "db_password" {
  description = "Password master de RDS"
  type        = string
  sensitive   = true
}
