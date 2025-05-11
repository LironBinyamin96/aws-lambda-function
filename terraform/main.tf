provider "aws" {
  region = "il-central-1"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_liron_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda" {
  function_name = "liron-lambda-auto-terraform"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = "function.zip"
  source_code_hash = filebase64sha256("function.zip")
}

data "aws_apigateway_api" "existing_api" {
  api_id = "mj92zct6nc"
}

resource "aws_apigateway_integration" "lambda_integration" {
  api_id           = data.aws_apigateway_api.existing_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.lambda.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigateway_route" "lambda_route" {
  api_id    = data.aws_apigateway_api.existing_api.id
  route_key = "POST /lambda"
  target    = "integrations/${aws_apigateway_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_apigatewayv2_api.existing_api.execution_arn}/*/*"
}
