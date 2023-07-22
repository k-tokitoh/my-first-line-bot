variable "prefix" {
  type = string
}

variable "lambda_role-arn" {
  type = string
}

variable "api-execution-arn" {
  type = string
}

variable "channel_access_token" {
  type = string
}

variable "channel_secret" {
  type = string
}


data "archive_file" "main" {
  type        = "zip"
  source_dir  = "${path.module}/dst/unzipped"
  output_path = "${path.module}/dst/main.zip"
}

resource "aws_lambda_function" "main" {
  filename         = data.archive_file.main.output_path
  function_name    = "${var.prefix}_main"
  role             = var.lambda_role-arn
  handler          = "index.handler" # jsにおいてentrypointとなる`{file name}.{func name}`
  source_code_hash = data.archive_file.main.output_base64sha256
  runtime          = "nodejs18.x"
  timeout          = 10
  environment {
    variables = {
      CHANNEL_ACCESS_TOKEN = "${var.channel_access_token}"
      CHANNEL_SECRET       = "${var.channel_secret}"
    }
  }
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowAPIGatewayPostApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api-execution-arn}/test/POST/"
}

output "lambda-invoke-arn" {
  value = aws_lambda_function.main.invoke_arn
}
