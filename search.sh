#!/usr/bin/env bash

# create working directories
mkdir -p compare
mkdir -p done/compare
mkdir -p done/vid

# clear log
echo "" > result.log
tail -f result.log &

# extract frames
for f in $(find vid -type f | grep -ve '\.md$')
do
    # prevent too many processes
    while [ $(jobs -r | wc -l) -gt $(grep -c ^processor /proc/cpuinfo) ]
    do
	    continue
    done
    (./frames.py ${f} && mv ${f} done/vid) &
done

# Wait for the frames extraction to finish
while [ $(jobs -r | wc -l) -gt 1 ]
do
	sleep 1
done

# compare the frames
for f in $(find compare -type f | grep -ve '\.md$')
do
    # prevent too many processes
    while [ $(jobs -r | wc -l) -gt $(grep -c ^processor /proc/cpuinfo) ]
    do
	    continue
    done
    (./classifier.py infer feature/classifier.pkl ${f} >> result.log 2> err.log ; mv ${f} done/compare) &
done
