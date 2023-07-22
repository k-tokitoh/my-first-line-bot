terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

# todo: local value

module "iam" {
  source = "../modules/iam"
  prefix = "line_bot"
}

module "lambda" {
  source            = "../modules/lambda"
  prefix            = "line_bot"
  lambda_role-arn   = module.iam.lambda_role-arn
  api-execution-arn = module.api_gateway.api-execution-arn
}

module "api_gateway" {
  source            = "../modules/api-gateway"
  prefix            = "line-bot"
  lambda-invoke-arn = module.lambda.lambda-invoke-arn
}

