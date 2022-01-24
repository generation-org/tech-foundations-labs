resource "aws_dynamodb_table" "ddbtable" {
  name         = "cheeper-${var.cohort_name}"
  hash_key     = "message"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "message"
    type = "S"
  }
}


resource "aws_iam_role_policy" "write_policy" {
  name = "cheeper-${var.cohort_name}-lambda_write_policy"
  role = aws_iam_role.writeRole.id

  policy = file("${path.module}/cheeper-lambda/write_policy.json")
}


resource "aws_iam_role_policy" "read_policy" {
  name = "cheeper-${var.cohort_name}-lambda_read_policy"
  role = aws_iam_role.readRole.id

  policy = file("${path.module}/cheeper-lambda/read_policy.json")
}


resource "aws_iam_role" "writeRole" {
  name = "cheeper-${var.cohort_name}-WriteRole"

  assume_role_policy = file("${path.module}/cheeper-lambda/assume_write_role_policy.json")

}


resource "aws_iam_role" "readRole" {
  name = "cheeper-${var.cohort_name}-ReadRole"

  assume_role_policy = file("${path.module}/cheeper-lambda/assume_read_role_policy.json")

}


resource "aws_lambda_function" "writeLambda" {

  function_name = "cheeper-${var.cohort_name}-writeLambda"
  s3_bucket     = aws_s3_bucket.cheeper-api.id
  s3_key        = "writecheep.zip"
  role          = aws_iam_role.writeRole.arn
  handler       = "writecheep.handler"
  runtime       = "nodejs12.x"
  environment {
    variables = {
      "cheeperTable" = aws_dynamodb_table.ddbtable.id
    }
  }
}


resource "aws_lambda_function" "readLambda" {

  function_name = "cheeper-${var.cohort_name}-readLambda"
  s3_bucket     = aws_s3_bucket.cheeper-api.id
  s3_key        = "readcheep.zip"
  role          = aws_iam_role.readRole.arn
  handler       = "readcheep.handler"
  runtime       = "nodejs12.x"
  environment {
    variables = {
      "cheeperTable" = aws_dynamodb_table.ddbtable.id
    }
  }
}



resource "aws_api_gateway_rest_api" "apiLambda" {
  name = "cheeper-${var.cohort_name}-API"

}


resource "aws_api_gateway_resource" "writeResource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "send_cheep"

}


resource "aws_api_gateway_method" "writeMethod" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = aws_api_gateway_resource.writeResource.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_resource" "readResource" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  parent_id   = aws_api_gateway_rest_api.apiLambda.root_resource_id
  path_part   = "get_cheeps"

}


resource "aws_api_gateway_method" "readMethod" {
  rest_api_id   = aws_api_gateway_rest_api.apiLambda.id
  resource_id   = aws_api_gateway_resource.readResource.id
  http_method   = "POST"
  authorization = "NONE"
}




resource "aws_api_gateway_integration" "writeInt" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.writeResource.id
  http_method = aws_api_gateway_method.writeMethod.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.writeLambda.invoke_arn

}


resource "aws_api_gateway_integration" "readInt" {
  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  resource_id = aws_api_gateway_resource.readResource.id
  http_method = aws_api_gateway_method.readMethod.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.readLambda.invoke_arn

}



resource "aws_api_gateway_deployment" "apideploy" {
  depends_on = [aws_api_gateway_integration.writeInt, aws_api_gateway_integration.readInt]

  rest_api_id = aws_api_gateway_rest_api.apiLambda.id
  stage_name  = "Prod"
}


resource "aws_lambda_permission" "writePermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.writeLambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/Prod/POST/send_cheep"

}


resource "aws_lambda_permission" "readPermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.readLambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.apiLambda.execution_arn}/Prod/POST/get_cheeps"

}


output "base_url" {
  value = aws_api_gateway_deployment.apideploy.invoke_url
}

data "archive_file" "readCheep" {
  type        = "zip"
  source_file = "${path.module}/cheeper-lambda/readcheep.js"
  output_path = "${path.module}/cheeper-lambda/readcheep.zip"
}

data "archive_file" "writeCheep" {
  type        = "zip"
  source_file = "${path.module}/cheeper-lambda/writecheep.js"
  output_path = "${path.module}/cheeper-lambda/writecheep.zip"
}

resource "aws_s3_bucket_object" "readCheep" {
  bucket = aws_s3_bucket.cheeper-api.id
  key    = "readcheep.zip"
  source = data.archive_file.readCheep.output_path
}

resource "aws_s3_bucket_object" "writeCheep" {
  bucket = aws_s3_bucket.cheeper-api.id
  key    = "writecheep.zip"
  source = data.archive_file.writeCheep.output_path
}

resource "aws_s3_bucket" "cheeper-api" {}