output "source_bucket_id" {
    value       = aws_s3_bucket.source_bucket.id
    description = "Source Bucket ID"
}

output "source_bucket_arn" {
    value       = aws_s3_bucket.source_bucket.arn
    description = "Source Bucket ARN"
}

output "destination_bucket_arn" {
    value       = aws_s3_bucket.destination_bucket.arn
    description = "Destination Bucket ARN"
}

output "destination_bucket_id" {
    value       = aws_s3_bucket.destination_bucket.id
    description = "Destination Bucket ID"
}
