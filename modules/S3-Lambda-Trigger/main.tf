# LAMBDA ROLE
resource "aws_iam_role" "lambda_iam_role" {
    name = join("-", [var.lambda_name, "role"])

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# BASE PERMISSIONS
resource "aws_iam_role_policy_attachment" "base" {
    depends_on = [aws_iam_role.lambda_iam_role]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    role       = aws_iam_role.lambda_iam_role.name
}

#OPTIONAL POLICY ATTACHMENT
resource "aws_iam_role_policy" "lambda_iam_policy" {
    depends_on = [aws_iam_role.lambda_iam_role]
    count = var.attach_custom_policy ? 1 : 0
    name = join("-", [var.lambda_name, "policy"])
    role = aws_iam_role.lambda_iam_role.id
    policy = var.policy
}

# LAMBDA BUILDER
resource "terraform_data" "install_python_dependencies" {
    provisioner "local-exec" {
        command = "bash build-script/builder.sh"

        environment = {
            source_code_path = var.source_code_path
            path_cwd         = path.cwd
            runtime          = var.runtime
            function_name    = var.lambda_name
        }
    }
}

data "archive_file" "lambda_zip" {
    depends_on      = [terraform_data.install_python_dependencies]
    type            = "zip"
    source_dir      = "${path.cwd}/lambda_pkg/"
    output_path     = var.output_path
    
}

# LAMBDA FUNCTION
resource "aws_lambda_function" "lambda_function" {
    depends_on       = [data.archive_file.lambda_zip,aws_iam_role.lambda_iam_role]
    filename         = var.output_path
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    role             = aws_iam_role.lambda_iam_role.arn
    function_name    = var.lambda_name
    handler          = "main.lambda_handler"
    runtime          = var.runtime
    timeout          = var.timeout
    memory_size      = var.memory_size

    environment {
        variables = var.lambda_environment_variables
    }
}

# LOG GROUP
resource "aws_cloudwatch_log_group" "function_log_group" {
    name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
    retention_in_days = 7
}

# LAMBDA PERMISSION
resource "aws_lambda_permission" "lambda_permission" {
    depends_on = [aws_lambda_function.lambda_function]
    statement_id  = "AllowS3Invoke"
    action        = "lambda:InvokeFunction"
    function_name = var.lambda_name
    principal     = "s3.amazonaws.com"
    source_arn    = var.source_s3_arn
}

# LAMBDA TRIGGER 
resource "aws_s3_bucket_notification" "lambda_trigger" {
    depends_on = [aws_lambda_permission.lambda_permission, aws_lambda_function.lambda_function]
    bucket = var.source_s3_id
    lambda_function {
        lambda_function_arn = aws_lambda_function.lambda_function.arn
        events              = var.s3_events
    }
}
