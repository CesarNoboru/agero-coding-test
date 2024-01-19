import sys
sys.path.append("..")
import pytest
import pandas as pd
import values
from process_csv import CSVProcess
from io import StringIO
import os

@pytest.mark.order(2)
def test_process_clean():
    test_data = StringIO(values.VALID_CSV)
    valid_data= pd.read_csv(
        StringIO(values.VALID_CSV_RETURN),
        engine="python",
        encoding="utf-8"
    ).to_string(index=False)
    os.environ['filter_threshold'] = '4.7'
    result = CSVProcess.process(test_data)
    assert result.to_string(index=False) == valid_data

@pytest.mark.order(3)
def test_process_dirty():
    test_data = StringIO(values.DIRTY_CSV)
    valid_data= pd.read_csv(
        StringIO(values.DIRTY_CSV_RETURN),
        engine="python",
        encoding="utf-8"
    ).to_string(index=False)
    os.environ['filter_threshold'] = '4.7'
    result = CSVProcess.process(test_data)
    assert result.to_string(index=False) == valid_data

@pytest.mark.order(1)
def test_process_error_no_threshold():
    test_data = StringIO(values.VALID_CSV)
    with pytest.raises(Exception, match=r"Error getting threshold from ENV variables:.*"):
        CSVProcess.process(test_data)


@pytest.mark.order(4)
def test_process_error_empty_csv():
    test_data = StringIO(values.EMPTY_CSV)
    with pytest.raises(Exception, match=r"Empty CSV:.*"):
        CSVProcess.process(test_data)

@pytest.mark.order(5)
def test_process_error_bad_threshold():
    test_data = StringIO(values.VALID_CSV)
    os.environ['filter_threshold'] = 'abc'
    with pytest.raises(Exception, match=r"Error getting threshold from ENV variables:.*"):
        CSVProcess.process(test_data)
