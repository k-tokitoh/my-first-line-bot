terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

variable "channel_access_token" {
  type = string
}

variable "channel_secret" {
  type = string
}


# todo: local value

module "iam" {
  source = "../modules/iam"
  prefix = "line_bot"
}

module "lambda" {
  source               = "../modules/lambda"
  prefix               = "line_bot"
  lambda_role-arn      = module.iam.lambda_role-arn
  api-execution-arn    = module.api_gateway.api-execution-arn
  channel_access_token = var.channel_access_token
  channel_secret       = var.channel_secret

}

module "api_gateway" {
  source            = "../modules/api-gateway"
  prefix            = "line-bot"
  lambda-invoke-arn = module.lambda.lambda-invoke-arn
}

