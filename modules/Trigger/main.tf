# LAMBDA TRIGGER 
resource "aws_s3_bucket_notification" "lambda_trigger" {
    depends_on = [aws_lambda_permission.lambda_permission]
    bucket = var.bucket_id
    lambda_function {
        lambda_function_arn = var.lambda_arn
        events              = ["s3:ObjectCreated:*"]
    }
}

# LAMBDA PERMISSION
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}