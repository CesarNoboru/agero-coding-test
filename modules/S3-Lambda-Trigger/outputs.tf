output "lambda_arn" {
    value       = aws_lambda_function.lambda_function.arn
    description = "Source Bucket ARN"
}

output "lambda_role_id" {
    value       = aws_iam_role.lambda_iam_role.id
    description = "Lambda Role ID"
}