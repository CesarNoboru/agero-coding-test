variable "bucket_id" {
    description = "Source Bucket ID."
}

variable "bucket_arn" {
    description = "Source Bucket arn."
}

variable "lambda_arn" {
    description = "Lambda ARN to be triggered by the event."
}

variable "lambda_name" {
    description = "Lambda NAME to be triggered by the event."
}
