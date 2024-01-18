import boto3
from json_logger import logger
import os

def s3_get(bucket, key):
    s3 = boto3.client("s3")
    logger.info(f"Downloading object {key} from source bucket {bucket}")
    try:
        csv = s3.get_object(Bucket=bucket, Key=key)
    except Exception as e:
        logger.error(f"Error getting Object from SOURCE S3: {e}")
        raise Exception(f"Error getting Objecti from SOURCE S3: {e}")
    
    logger.info(f"Downloaded object {key} from source bucket {bucket}")

    return csv['Body']

def s3_send(key, dataframe):
    try:
        bucket = os.environ["destination_bucket"]
        logger.debug(f"Using {bucket} as destination")
    except Exception as e:
        logger.error(f"Error getting destination bucket from ENV variables: {e}")
        raise Exception(f"Error getting destination bucket from ENV variables: {e}")

    logger.info(f"Sending object {key} to bucket {bucket}")

    s3 = boto3.resource("s3")

    try:
        object = s3.Object(
            bucket_name=bucket, 
            key=key
        )
        object.put(
            Body=dataframe.to_string(index=False)
        )
    except Exception as e:
        logger.error(f"Error sending Object to DESTINATION S3: {e}")
        raise Exception(f"Error sending Object to DESTINATION S3: {e}")
    
    logger.info(f"Sent object {key} to bucket {bucket}")
    return