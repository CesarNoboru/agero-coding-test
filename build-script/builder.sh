#!/bin/bash

cd $path_cwd

if [ -f "lambda.zip"]; then
    rm -Rf lambda.zip
fi

virtualenv -p $runtime env-lambda-pkg
source env-lambda-pkg/bin/activate
FILE=$source_code_path/reqs.txt
pip install -q -r $FILE --upgrade
deactivate


dir_name=lambda_pkg/

if [ -d "lambda_pkg"]
then
    rm -Rf ./lambda_pkg/*
else

    mkdir -p $dir_name
fi

cp -r $path_cwd/env-lambda-pkg/lib/$runtime/site-packages/* $path_cwd/$dir_name
cp -r $source_code_path/*.py $path_cwd/$dir_name

rm -rf $path_cwd/env-lambda-pkg/

