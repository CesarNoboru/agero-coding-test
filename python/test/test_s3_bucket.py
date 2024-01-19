import sys
sys.path.append("..")
import pytest
from tempfile import NamedTemporaryFile
from s3_bucket import S3Client
import values
import pandas as pd
from io import StringIO
import os



@pytest.mark.order(3)
def test_send(s3_client, s3_test):
    test_data = StringIO(values.VALID_CSV)
    df = pd.read_csv(test_data, engine="python", encoding="utf-8")
    my_client = S3Client()
    os.environ["destination_bucket"] = "dst-bucket"
    assert my_client.send("test-file", df) == True

@pytest.mark.order(4)
def test_get(s3_client, s3_test):
    with NamedTemporaryFile(delete=True, suffix=".csv") as tmp:
        with open(tmp.name, "w", encoding="UTF-8") as f:
            f.write(values.VALID_CSV)

        s3_client.upload_file(tmp.name, "src-bucket", tmp.name)

    s3 = S3Client()
    csv = s3.get("src-bucket", tmp.name)
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