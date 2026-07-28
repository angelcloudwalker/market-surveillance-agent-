output "api_url" {
  value       = aws_apigatewayv2_stage.default.invoke_url
  description = "POST /analizar para invocar el orquestador"
}
