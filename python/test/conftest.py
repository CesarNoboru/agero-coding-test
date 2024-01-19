import pytest
import os
import boto3
from moto import mock_s3

@pytest.fixture
def aws_credentials():
    os.environ["AWS_ACCESS_KEY_ID"] = "test-cred"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "test-cred"
    os.environ["AWS_SECURITY_TOKEN"] = "test-cred"
    os.environ["AWS_SESSION_TOKEN"] = "test-cred"

@pytest.fixture
def s3_client(aws_credentials):
    with mock_s3():
        conn = boto3.client("s3", region_name="us-east-1")
        yield conn

@pytest.fixture
def src_bucket_name():
    return "src-bucket"

@pytest.fixture
def dst_bucket_name():
    return "dst-bucket"

@pytest.fixture
def s3_test(s3_client, src_bucket_name, dst_bucket_name):
    s3_client.create_bucket(Bucket=src_bucket_name)
    s3_client.create_bucket(Bucket=dst_bucket_name)
    yield