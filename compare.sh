#!/usr/bin/env bash

echo "" > out.log

tail -f out.log &

for f in $(find compare -type f | grep -ve '.md$')
do
    ./classifier.py infer feature/classifier.pkl ${f} >> out.log
done
