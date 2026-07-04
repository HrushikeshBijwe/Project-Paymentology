resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project_name}-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "root_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_rest_api.this.root_resource_id
  http_method             = aws_api_gateway_method.root_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP"
  uri                     = "http://${var.alb_dns_name}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "INTERNET"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy_any" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP"
  uri                     = "http://${var.alb_dns_name}/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "INTERNET"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(join("|", [
      aws_api_gateway_method.root_any.http_method,
      aws_api_gateway_method.proxy_any.http_method,
      aws_api_gateway_integration.root_any.uri,
      aws_api_gateway_integration.proxy_any.uri,
      var.stage_name,
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.root_any,
    aws_api_gateway_integration.proxy_any,
  ]
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name
}
