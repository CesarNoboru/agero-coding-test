import logging
from pythonjsonlogger import jsonlogger
import os

handler = logging.StreamHandler()
format_str = '%(asctime)%(name)%(levelname)%(message)%(lineno)%(funcName)'
formatter = jsonlogger.JsonFormatter(format_str)
handler.setFormatter(formatter)
logger = logging.getLogger('AgeroExercise')
logger.addHandler(handler)
if "log_level" in os.environ:
    log_level = getattr(logging, os.environ["log_level"].upper())
    logger.setLevel(log_level)
else:
    logger.setLevel(logging.DEBUG)
logger.propagate = False