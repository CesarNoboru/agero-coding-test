#!/bin/bash

dir_name=lambda_pkg/
venv_name=env-lambda-pkg

cd $path_cwd

if [ -f "lambda.zip" ]; then
    rm -Rf lambda.zip
fi

virtualenv -p $runtime $venv_name
source $venv_name/bin/activate
FILE=$source_code_path/reqs.txt
pip install -q -r $FILE --upgrade
deactivate



if [ -d "$dir_name" ]; then
    rm -Rf ./$dir_name/*
else

    mkdir -p $dir_name
fi

cp -r $path_cwd/$venv_name/lib/$runtime/site-packages/* $path_cwd/$dir_name
cp -r $source_code_path/*.py $path_cwd/$dir_name

rm -rf $path_cwd/$venv_name/

