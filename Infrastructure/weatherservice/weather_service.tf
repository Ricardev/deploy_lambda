

locals {
  weatherLambdaOutputhPath = "weather_lambda_function.zip"
  weatherLambdaSourceDir = "${path.root}/../App/weather_lambda_function_source"
}

################## API GATEWAY #################
//Careful with subsequent deploys in Api Gateway since it isn't handled smoothly and you need to manually deploy in aws. See if there's a workaround already
resource "aws_api_gateway_rest_api" "RestAPI" {
  name = "RestAPI"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
// Há 2 modos de escrever as configurações do Gateway, em Jsonencode ou através do resource method e integration
# body = jsonencode({
#   openapi = "3.0.1"
#   info = {
#     title = "example"
#     version = "1.0"
#   }
#   paths = {
#     "/{proxy+}" = {
#       httpMethod = "ANY"
#       payloadFormatVersion = "1.0"
#       type = "AWS_PROXY"
#       uri= module.lambda.lambda_invoke_arn
#     }
#   }
# })

resource "aws_api_gateway_deployment" "GatewayDeployment" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_method.WeatherForecastMethod.id,
    aws_api_gateway_integration.WeatherForecastIntegration.id,
    aws_api_gateway_resource.APIGateway.id]))
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.lambda_root, aws_api_gateway_integration.WeatherForecastIntegration]
}

resource "aws_api_gateway_stage" "GatewayStage" {
  deployment_id = aws_api_gateway_deployment.GatewayDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  stage_name    = "stage"
}


resource "aws_api_gateway_resource" "APIGateway" {
  parent_id   = aws_api_gateway_rest_api.RestAPI.root_resource_id
  path_part   = "{proxy+}" //Proxy behavior, which means that this resource will match *any* request path.
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
}

resource "aws_api_gateway_method" "WeatherForecastMethod" {
  authorization = "NONE"
  http_method = "ANY" //Junto com o path_part, toda requisição vai dar match com esse recurso.
  resource_id = aws_api_gateway_resource.APIGateway.id
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
}

resource "aws_api_gateway_integration" "WeatherForecastIntegration" {
  http_method = aws_api_gateway_method.WeatherForecastMethod.http_method
  resource_id = aws_api_gateway_method.WeatherForecastMethod.resource_id
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  type        = "AWS_PROXY"
  uri = aws_lambda_function.weatherLambda.invoke_arn
  integration_http_method = "POST" //This needs to be POST, since the communication from Api Gateway to Lambda functions is with POST Method.
}

//Unfortunately the proxy resource cannot match an empty path at the root of the API. 
// To handle that, a similar configuration must be applied to the root resource that is built in to the REST API object:
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  resource_id   = aws_api_gateway_rest_api.RestAPI.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.weatherLambda.invoke_arn
}

########### LAMBDA #############
resource "aws_lambda_function" "weatherLambda" {
  function_name = "weather_forescast_lambda"
  filename = local.weatherLambdaOutputhPath
  role = aws_iam_role.weather_lambda_role.arn
  runtime = "dotnet8"
  source_code_hash = data.archive_file.weatherLambdaCode.output_base64sha256
  handler = "LambdaService::LambdaService.LambdaEntrypoint::FunctionHandlerAsync"
}

data "archive_file" "weatherLambdaCode" {
  output_path = local.weatherLambdaOutputhPath
  type        = "zip"
  source_dir = local.weatherLambdaSourceDir
}


################# IAM #####################

resource "aws_iam_role" "weather_lambda_role" {
  name = "weather_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_data.json
}

//For Lambda functions, access is granted using the aws_lambda_permission resource, which should be added to the lambda.tf file created in an earlier step:
resource "aws_lambda_permission" "APIGatewayAccessWeatherLambda" {
  statement_id = "AllowAPIGatewayInvoke"
  action             = "lambda:InvokeFunction"
  function_name      = aws_lambda_function.weatherLambda.function_name
  principal          = "apigateway.amazonaws.com"
  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*/*"
  
  depends_on = [
    aws_lambda_function.weatherLambda
  ]
}


data "aws_iam_policy_document" "lambda_role_data" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}