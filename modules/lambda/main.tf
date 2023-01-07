resource "aws_lambda_function" "function" {
  filename         = "${path.module}/files/${var.zip_file_name}"
  function_name    = var.function_name
  role             = var.lambda_role
  source_code_hash = filebase64sha256("${path.module}/files/${var.zip_file_name}")
  runtime          = "nodejs16.x"
  handler          = "${var.function_name}/index.handler"

  publish     = true
  timeout     = 5
  memory_size = 128
}



# data "archive_file" "init" {
#   type        = "zip"
#   source_file = "${path.module}/${var.source_file_name}/"
#   source {

#     filename = 
#   }
#   output_path = "${path.module}/files/${var.zip_file_name}"
# }
