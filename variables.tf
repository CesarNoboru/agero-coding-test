variable "lambda_name" {
    description = "Name for the Lambda function."
    default     = "agero-case-lambda"
}

variable "filter_threshold" {
    description = "Threshold to be used when filtering data inside CSV object."
    default     = "4.7"
}

variable "lambda_timeout" {
    description = "Lambda timeout."
    default     = "60"
}

variable "prefix_bucket_name" {
    description = "Prefix name for both S3, source and destination."
    default     = "agero-case-s3"
}

variable "memory_size" {
    description = "Lambda RAM memory."
    default     = "128"
}