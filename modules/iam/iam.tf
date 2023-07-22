variable "prefix" {
  type = string
}

resource "aws_iam_role" "lambda" {
  name = "${var.prefix}_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "0"
        Principal = {
          # todo: 狭くする
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attach" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "api_gateway" {
  name = "${var.prefix}_api_gateway_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "0"
        Principal = {
          # todo: 狭くする
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_invoke" {
  name = "${var.prefix}_lambda_invoke_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
        ]
        Effect = "Allow"
        # todo: 狭くする
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_role_policy_attach" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = aws_iam_policy.lambda_invoke.arn
}

output "lambda_role-arn" {
  value = aws_iam_role.lambda.arn
}
