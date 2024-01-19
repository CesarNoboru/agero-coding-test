VALID_CSV="""
random_nums
10
123.0
0
-1
33
12.2
0.2
-99.1
0.1
1
"""

VALID_CSV_RETURN="""
random_nums
10.0
123.0
33.0
12.2
"""

EMPTY_CSV=""

DIRTY_CSV="""
header
1a
bsd
10
09.1
-1
10.1
4.6
4.7
"""

DIRTY_CSV_RETURN="""
header
10
09.1
10.1
"""

VALID_EVENT = {
    "Records": [
        {
            "s3": {
                "bucket": {
                    "name": "src-bucket"
                },
                "object": {
                    "key" : "TEST_KEY"
                }
            }
        }
    ]
}

INVALID_EVENT = {}