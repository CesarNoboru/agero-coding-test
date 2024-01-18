#!/bin/bash
export source_code_path=$(pwd)/python
export path_cwd=$(pwd)
export runtime="python3.8"
function_name="agero-case-lambda"

/bin/bash ./build-script/builder.sh

(cd lambda_pkg && zip -r ../lambda.zip ./*)

aws lambda update-function-code --function-name $function_name --zip-file fileb://lambda.zip

rm -Rf lambda.zip lambda_pkg