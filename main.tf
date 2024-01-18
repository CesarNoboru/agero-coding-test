terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    backend "s3" {
        bucket         = "agero-terraform-backend-bucket"
        key            = "terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "agero-terraform-backend-table"
    }
}

provider "aws" {
    region                  = "us-east-1"
}


# CREATES BOTH S3 BUCKETS
module "s3" {
    source = "./modules/S3"

    prefix_bucket_name = var.prefix_bucket_name
}

# CREATES LAMBDA FUNCTION
module "lambda" {
    source = "./modules/Lambda"

    lambda_name = var.lambda_name
    destination_s3_arn = module.s3.destination_bucket_arn
    destination_s3_id = module.s3.destination_bucket_id
    source_s3_arn = module.s3.source_bucket_arn
    filter_threshold = var.filter_threshold
    timeout = var.lambda_timeout
    source_code_path = "${path.cwd}/python"
}

# CREATES LAMBDA TRIGGER ON S3 EVENT
module "trigger" {
    depends_on = [module.lambda, module.s3]
    source = "./modules/Trigger"

    bucket_id = module.s3.source_bucket_id
    bucket_arn = module.s3.source_bucket_arn
    lambda_arn = module.lambda.lambda_arn
    lambda_name = var.lambda_name
}