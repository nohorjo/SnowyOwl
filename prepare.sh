#!/usr/bin/env bash

# Create directory for aligned data and feature
rm -rf align
mkdir align
rm -rf feature
mkdir feature

# Create threads for preprocessing the images
for N in {1..$(grep -c ^processor /proc/cpuinfo)}
	do ./align-dlib.py raw align outerEyesAndNose align --size 96 &
done

# Wait for the preprocessing to finish
while [ $(jobs -r | wc -l) -gt 0 ]
do
	sleep 1
done

# Generate representations
./batch-represent/main.lua -outDir feature -data align

# Create classification model
./classifier.py train feature
