# Agero Coding Test
This is a coding test for a SRE contractor position in Agero

### Description

Develop a AWS Lambda function that is triggered by new CSV files uploaded to an S3 bucket. This function should read the CSV file, filter its content based on specific criteria, and then store the filtered data in a different S3 bucket. Expect to be able to answer detailed questions around your implementation.

#### Coding exercise

1.  Setup AWS Resources (using Terraform)
    
    a.  Create 2 S3 buckets: one for CSV uploads (source bucket) and one for filtered
        CSV data (destination bucket).
    b.  Set up an AWS Lambda function 
    c.  Ensure it has IAM roles to read from the source bucket and write to the
        destination bucket.        
    d.  Setup IAM roles and S3 buckets
        
2.  Configure S3 Trigger (using Terraform)
	a. Configure the source bucket to trigger the Lambda function on the 'ObjectCreated' event for new CSV files.

3. Lambda Function Logic
	a.  Read the CSV file that triggered the event from the source bucket.
    b.  Extract the file key and bucket name from the event data.
    c.  Parse the CSV file
    d.  Select rows where numerical values that exceed 4.7
    e.  Save the selected rows as a new CSV file to the destination bucket.

## Repository Structure

```bash
├── build-script
│   ├── (scripts used to build and update lambda deployment packages)
├── modules
│   ├── (terraform modules)
├── python
│   ├── (python code)
└── (main terraform code using modules)
```

## Terraform

This portion of the code was split according to the services and order of creation. It uses S3 and dynamoDB (previously created) as backend.

### Lambda

Creates Lambda role, policies, log group, function and also automates the deployment package creation while deploying.

### S3

Creates both S3 Buckets, source and destination.

### Trigger

Creates the trigger on S3 ObjectCreated event invoking the lambda function.

## Python

The code was split by context to make it easier to read

### json_logger

Sets the configuration for the logger using pythonjsonlogger to create a single line JSON object as log to make easier to read and integrate with any log aggregator.

### process_csv

Processes the CSV object according to the threshold filter set on the lambda environment variable. 

### s3_bucket

Simply gets the object from the source bucket, and sends the filtered object to the destination bucket.

### main

Main code filters bucket and key from the event and calls previously mentioned modules.

## Scripts

### builder

Script used by the terraform Lambda module to automate the deployment package creation. It uses virtualenv to install the requisites mentioned in reqs.txt, moves all dependencies and code to a unique directory to be used by terraform data archive_file.

### update-code

Script created to update only the code itself, it invokes builder script, zips and send the deployment package to the lambda function.


## Requisites

- Terraform v1.7.0
- Python3.8
- virtualenv
- AWS credentials
- Terraform backend S3 and DynamoDB

## Usage

#### Deployment

(Optional) Edit terraform backend (backend.conf) to suit your AWS account environment
```bash
terraform init -backend-config=backend.conf
terraform plan
terraform deploy
```

#### Update Lambda Code

```bash
./build-script/update-code.sh
```