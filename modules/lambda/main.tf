resource "aws_lambda_function" "function" {
  filename         = "${path.module}/files/${var.zip_file_name}"
  function_name    = var.function_name
  role             = var.lambda_role
  source_code_hash = filebase64sha256("${path.module}/files/${var.zip_file_name}")
  runtime          = "nodejs16.x"
  handler          = "index.handler"

  publish     = true
  timeout     = 30
  memory_size = 256
}
