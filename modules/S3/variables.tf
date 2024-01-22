variable "prefix_bucket_name" {
    description = "Prefix name S3 bucket"
    default     = "agero-case-s3"
}

variable "suffix_bucket_name" {
    description = "Suffix name for S3 buckets, the amount of items in this list, will set the number of buckets created."
    default     = ["bucket"]
}