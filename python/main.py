from json_logger import logger
from s3_bucket import S3Client
from process_csv import CSVProcess
def get_info(event):
    logger.debug(event)
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        logger.debug(f"Bucket {bucket}, Key {key}")
    except Exception as e:
        logger.error(f"Error reading event: {e}")
        raise Exception(f"Error reading event: {e}")
    
    return bucket, key

def lambda_handler (event, context):
    logger.info("Starting Lambda")
    bucket, key = get_info(event)
    s3 = S3Client("us-east-1")
    csv = s3.get(bucket, key)
    result = CSVProcess.process(csv)
    s3.send(key, result)
    logger.info("Processing Completed.")
    return 200