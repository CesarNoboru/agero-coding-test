import sys
sys.path.append("..")
import boto3
import pytest
from main import *
import values
from moto import mock_s3
from tempfile import NamedTemporaryFile

class TestContext:
    aws_request_id = "TEST_ID"


def test_get_info():
    bucket, key = get_info(values.VALID_EVENT)
    assert bucket == "src-bucket"
    assert key == "TEST_KEY"


def test_lambda_handler(s3_client, s3_test):
    with NamedTemporaryFile(delete=True, suffix=".csv") as tmp:
        with open(tmp.name, "w", encoding="UTF-8") as f:
            f.write(values.VALID_CSV)
        s3_client.upload_file(tmp.name, "src-bucket", tmp.name)
    event = values.VALID_EVENT
    event['Records'][0]['s3']['object']['key'] = tmp.name
    os.environ['filter_threshold'] = '4.7'
    res = lambda_handler(event, TestContext)
    amzn_id = os.environ["request_id"]
    assert res == 200
    assert amzn_id == "TEST_ID"

def test_get_info_error():
    with pytest.raises(Exception):
        get_info(values.INVALID_EVENT, match=r"Error reading event:.*")

