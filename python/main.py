from json_logger import logger
from s3_bucket import s3_get, s3_send
from process_csv import process


def lambda_handler (event, context):
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        logger.debug(f"Bucket {bucket}, Key {key}")
    except Exception as e:
        logger.error(f"Error reading event: {e}")
        raise Exception(f"Error reading event: {e}")
    
    csv = s3_get(bucket, key)
    result = process(csv)
    s3_send(key, result)

    return 200