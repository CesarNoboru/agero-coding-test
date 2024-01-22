variable "lambda_name" {
    description = "Name for the Lambda function."
    default     = "agero-case-lambda"
}

variable "source_s3_arn" {
    description = "Source S3 Bucket ARN that will trigger the lambda."
    default     = "*"
}
variable "source_s3_id" {
    description = "Source S3 Bucket NAME that will trigger the lambda."
    default     = "*"
}

variable "memory_size" {
    description = "Amount of memory in MB your Lambda."
    default     = "128"
}

variable "timeout" {
    description = "Function timeout"
    default     = "300"
}

variable "source_code_path" {
    description = "Path to the source file or directory containing your Lambda source code"
}

variable "output_path" {
    description = "Path to the function's deployment package within local filesystem. eg: /path/to/lambda.zip"
    default     = "lambda.zip"
}

variable "runtime" {
    description = "Lambda runtime"
}

variable "lambda_environment_variables" {
    description = "Lambda environment variables"
    default = {}
}

variable "s3_events" {
    description = "List of S3 events to trigger Lambda function."
}

variable "policy" {
    description = "Policy document to be attached on Lambda Role."
    default = null
}

variable "attach_custom_policy" {
    description = "Bool that indicates if will be attached a custom policy."
    default = false
}