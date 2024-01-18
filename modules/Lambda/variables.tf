variable "lambda_name" {
    description = "Name for the Lambda function."
    default     = "agero-case-lambda"
}

variable "destination_s3_arn" {
    description = "S3 Bucket that will receive the filtered data."
    default     = "*"
}

variable "source_s3_arn" {
    description = "Source S3 Bucket that will trigger the lambda."
    default     = "*"
}

variable "filter_threshold" {
    description = "Threshold to be used when filtering data inside CSV object."
    default     = "4.7"
}

variable "destination_s3_id" {
    description = "Destination S3 name."
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
