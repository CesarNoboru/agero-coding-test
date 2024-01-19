import sys
sys.path.append("..")
import pytest
from tempfile import NamedTemporaryFile
from s3_bucket import S3Client
from moto import mock_s3
import os
import boto3
import values
import pandas as pd
from io import StringIO


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
def bucket_name():
    return "my-test-bucket"


@pytest.fixture
def s3_test(s3_client, bucket_name):
    s3_client.create_bucket(Bucket=bucket_name)
    yield

@pytest.mark.order(3)
def test_send(s3_client, s3_test):
    test_data = StringIO(values.VALID_CSV)
    df = pd.read_csv(test_data, engine="python", encoding="utf-8")
    my_client = S3Client()
    os.environ["destination_bucket"] = "my-test-bucket"
    assert my_client.send("test-file", df) == True

@pytest.mark.order(4)
def test_get(s3_client, s3_test):
    with NamedTemporaryFile(delete=True, suffix=".csv") as tmp:
        with open(tmp.name, "w", encoding="UTF-8") as f:
            f.write(values.VALID_CSV)

        s3_client.upload_file(tmp.name, "my-test-bucket", tmp.name)

    s3 = S3Client()
    csv = s3.get("my-test-bucket", tmp.name)
    assert csv.read().decode('utf-8') == values.VALID_CSV

@pytest.mark.order(1)
def test_send_no_bucket_env(s3_client, s3_test):
    test_data = StringIO(values.VALID_CSV)
    df = pd.read_csv(test_data, engine="python", encoding="utf-8")
    my_client = S3Client()
    with pytest.raises(Exception, match=r"Error getting destination bucket from ENV variables:.*"):
        my_client.send("test-file", df)

@pytest.mark.order(2)
def test_send_no_bucket(s3_client, s3_test):
    test_data = StringIO(values.VALID_CSV)
    df = pd.read_csv(test_data, engine="python", encoding="utf-8")
    my_client = S3Client()
    os.environ["destination_bucket"] = "no-bucket"
    with pytest.raises(Exception, match=r"Error sending Object to DESTINATION S3:.*"):
        my_client.send("test-file", df)

@pytest.mark.order(6)
def test_get_error_bucket(s3_client, s3_test):
    s3 = S3Client()
    with pytest.raises(Exception, match=r"Error getting Object from SOURCE S3:.*"):
        s3.get("no-bucket", "whatever")

@pytest.mark.order(5)
def test_get_error_key(s3_client, s3_test):
    s3 = S3Client()
    with pytest.raises(Exception, match=r"Error getting Object from SOURCE S3:.*"):
        s3.get("my-test-bucket", "whatever")