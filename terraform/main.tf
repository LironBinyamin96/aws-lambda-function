provider "aws" {
  region = "il-central-1"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_liron_role_gitlab"

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

# Lambda Function
resource "aws_lambda_function" "lambda" {
  function_name = "liron-lambda-gitlab-2"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = "function.zip"
  source_code_hash = filebase64sha256("function.zip")
}

# Existing API Gateway
data "aws_api_gateway_rest_api" "existing_api" {
  name = "imtech"
}
# Custom policy to allow Lambda access to DynamoDB table imtech
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda_dynamodb_full_access_imtech_gitlab"
  description = "Allow Lambda to access DynamoDB table imtech"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource = "arn:aws:dynamodb:il-central-1:314525640319:table/imtech"
      }
    ]
  })
}

# Attach the custom policy to the Lambda role
resource "aws_iam_policy_attachment" "attach_lambda_dynamodb_policy" {
  name       = "lambda_dynamodb_policy_attachment_gitlab"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Root Resource
data "aws_api_gateway_resource" "root" {
  rest_api_id = data.aws_api_gateway_rest_api.existing_api.id
  path        = "/"
}

# New Resource under root
resource "aws_api_gateway_resource" "lambda_resource" {
  rest_api_id = data.aws_api_gateway_rest_api.existing_api.id
  parent_id   = data.aws_api_gateway_resource.root.id
  path_part   = "liron-lambda-gitlab-2"
}

# Method on new resource
resource "aws_api_gateway_method" "post_lambda" {
  rest_api_id   = data.aws_api_gateway_rest_api.existing_api.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Integration with Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = data.aws_api_gateway_rest_api.existing_api.id
  resource_id             = aws_api_gateway_resource.lambda_resource.id
  http_method             = aws_api_gateway_method.post_lambda.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_api_gateway_rest_api.existing_api.execution_arn}/*/ANY/liron-lambda-auto-terraform"
}

# Deployment (uses existing "default" stage)
resource "aws_api_gateway_deployment" "lambda_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  rest_api_id = data.aws_api_gateway_rest_api.existing_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.lambda_resource.id,
      aws_api_gateway_method.post_lambda.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }
  stage_name = "default" 
}
