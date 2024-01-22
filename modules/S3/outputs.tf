output "bucket_ids" {
    value       = [ for s3 in aws_s3_bucket.s3_bucket : s3.id ]
    description = "S3 Bucket IDs"
}

output "bucket_arns" {
    value       = [ for s3 in aws_s3_bucket.s3_bucket : s3.arn ]
    description = "S3 Bucket ARNs"
}
