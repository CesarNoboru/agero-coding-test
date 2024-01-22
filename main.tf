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

# CREATES POLICY BASED ON A TEMPLATE TO ATTACH TO LAMBDA
data "template_file" "policy" {
    template = "${file("${path.cwd}/policy.json")}"
    vars = {
        SOURCE_ARN = one([ for arn in module.s3.bucket_arns : arn if can(regex("source", arn)) ])
        DESTINATION_ARN = one([ for arn in module.s3.bucket_arns : arn if can(regex("destination", arn)) ])
    }
}

# CREATES LAMBDA FUNCTION TRIGGERED BY S3 EVENT
module "s3_lambda_trigger" {
    source = "./modules/S3-Lambda-Trigger"

    lambda_name = var.lambda_name
    source_s3_arn = one([ for arn in module.s3.bucket_arns : arn if can(regex("source", arn)) ])
    source_s3_id = one([ for id in module.s3.bucket_ids : id if can(regex("source", id)) ])
    timeout = var.lambda_timeout
    source_code_path = "${path.cwd}/python"
    runtime = var.lambda_runtime
    lambda_environment_variables = {
        filter_threshold = var.filter_threshold
        destination_bucket = one([ for id in module.s3.bucket_ids : id if can(regex("destination", id)) ])
    }
    attach_custom_policy = true
    policy = "${data.template_file.policy.rendered}"
    s3_events = var.s3_events
}
