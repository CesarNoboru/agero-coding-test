# Agero Coding Test

This is a coding test for a SRE contractor position in Agero

### Description

Develop a AWS Lambda function that is triggered by new CSV files uploaded to an S3 bucket. This function should read the CSV file, filter its content based on specific criteria, and then store the filtered data in a different S3 bucket. Expect to be able to answer detailed questions around your implementation.

#### Coding exercise

1. Setup AWS Resources (using Terraform)
	1. Create 2 S3 buckets: one for CSV uploads (source bucket) and one for filtered CSV data (destination bucket).
	2. Set up an AWS Lambda function
	3. Ensure it has IAM roles to read from the source bucket and write to the destination bucket.
	4. Setup IAM roles and S3 buckets

2. Configure S3 Trigger (using Terraform)
	3. Configure the source bucket to trigger the Lambda function on the 'ObjectCreated' event for new CSV files.

3. Lambda Function Logic
	4. Read the CSV file that triggered the event from the source bucket.
	5. Extract the file key and bucket name from the event data.
	6. Parse the CSV file
	7. Select rows where numerical values that exceed 4.7
	8. Save the selected rows as a new CSV file to the destination bucket.

## Repository Structure

```bash

├──  build-script (Scripts used to build and update lambda deployment packages)
├──  modules (Terraform modules)
│  ├── S3-Lambda-Trigger (Lambda triggered by S3 event packaging and deployment)
│  ├── S3 (Create S3 Buckets)
├──  python (Python code)
│  ├── test (Unit testing with pytest)
└── (Main terraform code using modules)

```

## Terraform

This portion of the code was split in two modules to be reused outside of this projects context.
It uses S3 and DynamoDB (previously created) as backend.

### S3-Lambda Trigger

This module creates a Lambda function triggered by an S3 event.

Creates Lambda function with basic IAM permissions, triggeded by S3 event, CloudWatch log group, automates the deployment package creation while deploying.
Can also attach a custom policy to Lambda's IAM Role.

#### Variables
`lambda_name` Lambda function's name.
`memory_size` Amount of memory in MB for the Lambda function.
`timeout` Lambda function timeout in seconds.
`runtime` Lambdas runtime version.
`source_code_path` Path for the Lambda's source code directory.
`output_path` Path where the Lambda's deployment package will be created locally.
`lambda_environment_variables` Enviroment variables map for Lambda function.
`source_s3_arn` S3 Bucket ARN that will trigger the Lambda function.
`source_s3_id` S3 Bucket ID (Name) that will trigger the Lambda function.
`s3_events` S3 Events that will trigger the Lambda function.
`attach_custom_policy` Boolean that indicates if a custom policy will be attached to the Lambda's IAM Role.
`policy` Custom IAM Policy to be attached to Lambda's IAM Role.

#### Outputs

`lambda_arn` Lambda function's ARN.
`lambda_role_id` Lambda's IAM Role ID.

### S3

This module can create as much private S3 Buckets as needed.

#### Variables
`prefix_bucket_name` Prefix string used on all S3 Bucket names to be created.
`suffix_bucket_name` List with suffixes for S3 Bucket names. This list will determine how many buckets will be created.

#### Outputs
`bucket_ids` List of S3 Bucket IDs (Names)
`bucket_arns` List of S3 Bucket ARNs

### Main Terraform Code

The main Terraform code uses `S3` module to create both S3 Buckets (source and destination).
Creates a policy document that allows the Lambda function to read from source S3 Bucket, and write on destination S3 Bucket based on the template `policy.json`.
Uses `S3-Lambda-Trigger` module to create the Lambda function triggered by an S3 event attaching the custom policy with IAM permissions.

## Python

The code was split by context to make it easier to read and maintain.

### json_logger

Sets the configuration for the logger using `python-json-logger` to create a single line JSON log to make easier reading and integrating with any aggregator. Its level is set by an environment variable `log_level`, if not set it will consider `DEBUG` by default. It uses the environment variable `request_id` stored by `main.lambda_handler` to provide Amazon Request ID from Lambda `context`.

Log example:
```bash
{ "timestamp":  "2024-01-19T16:53:55.095039Z", "name":  "AgeroExercise", "level":  "INFO", "message":  "Starting Lambda", "funcName":  "lambda_handler", "request_id":  "4db49312-622f-4f77-9c67-6ef1d6fd788b" }
```

### process_csv

Processes the CSV using `pandas` according to the threshold filter set on the lambda environment variable `filter_threshold`. This code will only consider numeric values in the first column from the CSV.

### s3_bucket

Simply gets the object from the source bucket, and sends the filtered object to the destination bucket set on lambda environment variable `destination_bucket`.

### main

Main code filters bucket and key from the `event`, stores Amazon Request ID from `context` to the environment variable `request_id` to be used by `json_logger` and calls previously mentioned modules.

## Scripts

### builder

Script used by the terraform Lambda module and update-code script to automate the deployment package creation. It uses virtualenv to install the requisites mentioned in reqs.txt, moves all dependencies and code to a unique directory to be used by terraform data archive_file.

### update-code

Script created to update only the deployment package, it invokes builder script, zips and send the deployment package to the lambda function.

## Requisites

### Deployment

- Terraform v1.7.0
- Python3.8
- virtualenv
- AWS credentials
- Terraform backend S3 and DynamoDB

### Tests 
- boto3
- pytest
- moto

## Usage

#### Test

```bash
cd python/tests
pytest
```


#### Deployment

(Optional) Edit terraform backend (backend.conf) to suit your AWS account environment.

```bash

terraform  init  -backend-config=backend.conf

terraform  plan

terraform  deploy

```

#### Update Lambda Code Only

```bash

./build-script/update-code.sh

```