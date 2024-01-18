import logging
from pythonjsonlogger import jsonlogger

handler = logging.StreamHandler()
format_str = '%(asctime)%(name)%(levelname)%(message)%(lineno)%(funcName)'
formatter = jsonlogger.JsonFormatter(format_str)
handler.setFormatter(formatter)
logger = logging.getLogger('AgeroExercise')
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)
logger.propagate = False