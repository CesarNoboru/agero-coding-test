terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    backend "s3" {}
}

provider "aws" {
    region                  = "us-east-1"
}


# CREATES BOTH S3 BUCKETS
module "s3" {
    source = "./modules/S3"

    prefix_bucket_name = var.prefix_bucket_name
    suffix_bucket_name = var.suffix_bucket_name
}

# CREATES LAMBDA FUNCTION
module "lambda" {
    source = "./modules/Lambda"

    lambda_name = var.lambda_name
    destination_s3_arn = one([ for arn in module.s3.bucket_arns : arn if can(regex("destination", arn)) ])
    destination_s3_id = one([ for id in module.s3.bucket_ids : id if can(regex("destination", id)) ])
    source_s3_arn = one([ for arn in module.s3.bucket_arns : arn if can(regex("source", arn)) ])
    filter_threshold = var.filter_threshold
    timeout = var.lambda_timeout
    source_code_path = "${path.cwd}/python"
}

# CREATES LAMBDA TRIGGER ON S3 EVENT
module "trigger" {
    depends_on = [module.lambda, module.s3]
    source = "./modules/Trigger"
    bucket_id = one([ for id in module.s3.bucket_ids : id if can(regex("source", id)) ])
    bucket_arn = one([ for arn in module.s3.bucket_arns : arn if can(regex("source", arn)) ])
    lambda_arn = module.lambda.lambda_arn
    lambda_name = var.lambda_name
}
