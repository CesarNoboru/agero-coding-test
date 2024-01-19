import logging
from pythonjsonlogger import jsonlogger
import os
from datetime import datetime

class CustomJsonFormatter(jsonlogger.JsonFormatter):
    def add_fields(self, log_record, record, message_dict):
        super(CustomJsonFormatter, self).add_fields(log_record, record, message_dict)
        if not log_record.get('timestamp'):
            now = datetime.now().strftime('%Y-%m-%dT%H:%M:%S.%fZ')
            log_record['timestamp'] = now
        if log_record.get('level'):
            log_record['level'] = log_record['level'].upper()
        else:
            log_record['level'] = record.levelname
        if "request_id" not in os.environ:
            os.environ["request_id"] = ""
        log_record["request_id"] = os.environ["request_id"]


handler = logging.StreamHandler()
format_str = '%(timestamp)%(name)%(level)%(message)%(funcName)%(request_id)'
formatter = CustomJsonFormatter(format_str)
handler.setFormatter(formatter)
logger = logging.getLogger('AgeroExercise')
logger.addHandler(handler)
if "log_level" in os.environ:
    log_level = getattr(logging, os.environ["log_level"].upper())
    logger.setLevel(log_level)
else:
    logger.setLevel(logging.DEBUG)
logger.propagate = False