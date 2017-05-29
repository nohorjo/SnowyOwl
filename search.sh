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
    # remove spaces from filename
    mv ${f} $(echo ${f} | sed 's/ /_/g') 2> /dev/null
    (./frames.py ${f} && mv ${f} done/vid) &
done

# Wait for the frames extraction to finish
while [ $(jobs -r | wc -l) -gt 1 ]
do
	continue
done
echo Extracted frames

# rotate frames
for f in $(find compare -type f | grep -ve '\.md$')
do
    # prevent too many processes
    while [ $(jobs -r | wc -l) -gt $(grep -c ^processor /proc/cpuinfo) ]
    do
	    continue
    done
    for r in 90 270
    do
        convert ${f} -rotate ${r} ${f%.*}_${r}.${f##*.} &
    done
done

# wait for rotation to finish
while [ $(jobs -r | wc -l) -gt 1 ]
do
	continue
done
echo Rotated frames

# compare the frames
for f in $(find compare -type f | grep -ve '\.md$')
do
    # prevent too many processes
    while [ $(jobs -r | wc -l) -gt $(grep -c ^processor /proc/cpuinfo) ]
    do
	    continue
    done
    echo Checking ${f}
    (./classifier.py infer feature/classifier.pkl ${f} >> result.log 2> err.log ; mv ${f} done/compare) &
done

# wait for comparisons to finish
while [ $(jobs -r | wc -l) -gt 1 ]
do
	continue
done
echo Done

# kill tail
kill $(jobs -p) > /dev/null 2> /dev/null