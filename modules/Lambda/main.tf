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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_iam_role.name
}

resource "aws_iam_role_policy" "lambda_iam_policy" {
    name = join("-", [var.lambda_name, "policy"])
    role = aws_iam_role.lambda_iam_role.id

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Sid":"AllowReadSource",
        "Action": [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:GetObjectVersion"
        ],
        "Effect": "Allow",
        "Resource": [
            "${var.source_s3_arn}",
            "${var.source_s3_arn}/*"
        ]
    },
    {
        "Sid":"AllowWriteDestination",
        "Action": [
            "s3:PutObject"
        ],
        "Effect": "Allow",
        "Resource": [
            "${var.destination_s3_arn}",
            "${var.destination_s3_arn}/*"
        ]
    }
    ]
}
EOF
}

# LAMBDA BUILDER
resource "terraform_data" "install_python_dependencies" {
    provisioner "local-exec" {
        command = "bash build-script/builder.sh"

        environment = {
            source_code_path = var.source_code_path
            path_cwd         = path.cwd
            path_module      = path.module
            runtime          = "python3.8"
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
    depends_on       = [data.archive_file.lambda_zip]
    filename         = var.output_path
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    role             = aws_iam_role.lambda_iam_role.arn
    function_name    = var.lambda_name
    handler          = "main.lambda_handler"
    runtime          = "python3.8"
    timeout          = var.timeout
    memory_size      = var.memory_size

    environment {
        variables = {
                filter_threshold = var.filter_threshold
                destination_bucket = var.destination_s3_id
            }
    }
}

# LOG GROUP
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 7
}
