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
            column_name = dataframe.columns[0]

            logger.debug(f"Column name: {column_name}")
            result = dataframe[pd.to_numeric(dataframe[column_name], errors='coerce') > threshold]
            logger.debug(result.to_string(index=False))
        except Exception as e:
            logger.error(f"Error filtering CSV with threshold: {e}")
            raise Exception(f"Error filtering CSV with threshold: {e}")
        
        return result