variable "prefix" {
  type = string
}

variable "lambda-invoke-arn" {
  type = string
}

resource "aws_api_gateway_rest_api" "main" {
  name = "${var.prefix}_api"
}

resource "aws_api_gateway_method" "post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  rest_api_id   = aws_api_gateway_rest_api.main.id
}

resource "aws_api_gateway_integration" "main" {
  http_method             = aws_api_gateway_method.post.http_method
  resource_id             = aws_api_gateway_rest_api.main.root_resource_id
  rest_api_id             = aws_api_gateway_rest_api.main.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda-invoke-arn
}

resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_integration.main
  ]
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "test"
  triggers = {
    redeployment = filebase64("${path.module}/api-gateway.tf")
  }
}

output "api-execution-arn" {
  value = aws_api_gateway_rest_api.main.execution_arn
}
