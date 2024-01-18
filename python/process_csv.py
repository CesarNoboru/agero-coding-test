import pandas as pd
from json_logger import logger
import os

class CSVProcess:
    @staticmethod
    def process(csv):
        try:
            dataframe = pd.read_csv(csv, header=0)
            logger.debug(dataframe.to_string(index=False))
        except Exception as e:
            logger.error(f"Error reading CSV: {e}")
            raise Exception(f"Error reading CSV: {e}")
        
        try:
            threshold = float(os.environ["filter_threshold"])
            logger.debug(f"Using {threshold}  as threshold")
        except Exception as e:
            logger.error(f"Error getting threshold from ENV variables: {e}")
            raise Exception(f"Error getting threshold from ENV variables: {e}")
        
        try:
            result = dataframe[dataframe['random_nums'] > threshold]
            logger.debug(result.to_string(index=False))
        except Exception as e:
            logger.error(f"Error filtering CSV with threshold: {e}")
            raise Exception(f"Error filtering CSV with threshold: {e}")
        
        return result