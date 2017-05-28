#!/usr/bin/env bash

echo "" > result.log

tail -f result.log &

for f in $(find compare -type f | grep -ve '.md$')
do
    ./classifier.py infer feature/classifier.pkl ${f} >> result.log
done
