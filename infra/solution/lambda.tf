# =============================================================================
# IAM — Role compartido para todas las Lambdas
# =============================================================================

resource "aws_iam_role" "lambda_exec" {
  name = "market-surveillance-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_invoke" {
  name = "market-surveillance-invoke-detectors"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = "arn:aws:lambda:${var.aws_region}:*:function:detector-*"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_bedrock" {
  name = "market-surveillance-bedrock"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
      Resource = "*"
    }]
  })
}

# =============================================================================
# Layer compartido — psycopg2 + shared/
# =============================================================================

resource "aws_lambda_layer_version" "shared" {
  filename            = "${path.module}/../../build/layer.zip"
  layer_name          = "market-surveillance-shared"
  compatible_runtimes = ["python3.12"]
  source_code_hash    = filebase64sha256("${path.module}/../../build/layer.zip")
}

# =============================================================================
# Variables de entorno comunes para detectores
# =============================================================================

locals {
  detector_env = {
    DB_HOST     = var.rds_endpoint
    DB_PORT     = "5432"
    DB_NAME     = "market_surveillance"
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password
  }
}

# =============================================================================
# Lambdas — Detectores (en VPC para alcanzar RDS por red privada)
# =============================================================================

resource "aws_lambda_function" "detector_wash_trading" {
  filename         = "${path.module}/../../build/detector_wash_trading.zip"
  function_name    = "detector-wash-trading"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = filebase64sha256("${path.module}/../../build/detector_wash_trading.zip")
  layers           = [aws_lambda_layer_version.shared.arn]

  environment { variables = local.detector_env }
  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
}

resource "aws_lambda_function" "detector_spoofing" {
  filename         = "${path.module}/../../build/detector_spoofing.zip"
  function_name    = "detector-spoofing"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = filebase64sha256("${path.module}/../../build/detector_spoofing.zip")
  layers           = [aws_lambda_layer_version.shared.arn]

  environment { variables = local.detector_env }
  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
}

resource "aws_lambda_function" "detector_concentration" {
  filename         = "${path.module}/../../build/detector_concentration.zip"
  function_name    = "detector-concentration"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = filebase64sha256("${path.module}/../../build/detector_concentration.zip")
  layers           = [aws_lambda_layer_version.shared.arn]

  environment { variables = local.detector_env }
  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
}

resource "aws_lambda_function" "detector_dormant" {
  filename         = "${path.module}/../../build/detector_dormant.zip"
  function_name    = "detector-dormant"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = filebase64sha256("${path.module}/../../build/detector_dormant.zip")
  layers           = [aws_lambda_layer_version.shared.arn]

  environment { variables = local.detector_env }
  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
}

resource "aws_lambda_function" "detector_structuring" {
  filename         = "${path.module}/../../build/detector_structuring.zip"
  function_name    = "detector-structuring"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = filebase64sha256("${path.module}/../../build/detector_structuring.zip")
  layers           = [aws_lambda_layer_version.shared.arn]

  environment { variables = local.detector_env }
  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }
}

# =============================================================================
# Lambda — Orquestador (fuera de VPC, solo invoca detectores)
# =============================================================================

resource "aws_lambda_function" "orchestrator" {
  filename         = "${path.module}/../../build/orchestrator.zip"
  function_name    = "market-surveillance-orchestrator"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = filebase64sha256("${path.module}/../../build/orchestrator.zip")
}
