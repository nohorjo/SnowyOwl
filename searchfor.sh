#!/usr/bin/env bash

# create working directories
mkdir -p done/compare
mkdir -p done/vid
mkdir -p done/found

corecount=$(grep -c ^processor /proc/cpuinfo)

# extract frames
for f in $(find vid -type f | grep -ve '\.md$')
do
    # prevent too many processes
    while [ $(jobs -r | wc -l) -gt ${corecount} ]
    do
	    continue
    done
    # remove spaces from filename
    mv ${f} $(echo ${f} | sed 's/ /_/g') 2> /dev/null
    (./frames.py ${f} && mv ${f} done/vid) &
done

# Wait for the frames extraction to finish
while [ $(jobs -r | wc -l) -gt 0 ]
do
	continue
done
echo Extracted frames

# rotate frames
for d in $(find compare -type d)
do
	for f in $(find ${d} -type f | grep -ve '\.md$' | grep -ve '\.rotated\..*')
	do
		# prevent too many processes
		while [ $(jobs -r | wc -l) -gt ${corecount} ]
		do
			continue
		done
		for r in 90 270
		do
			convert ${f} -rotate ${r} ${f%.*}_${r}.rotated.${f##*.} &
		done
	done
done

# wait for rotation to finish
while [ $(jobs -r | wc -l) -gt 0 ]
do
	continue
done
echo Rotated frames

function compareFrames(){
	echo Checking $1 | sed 's/compare\///g'
	for f in $(find $1 -type f | grep -ve '\.md$')
	do
		# prevent too many processes
		while [ $(jobs -r | wc -l) -gt ${corecount} ]
		do
			continue
		done
		local result=$(./classifier.py infer feature/classifier.pkl ${f} 2>> err.log)
		if [[ ${result} == *"$2"* ]]; then
  			echo FOUND IN ${f}
  			local path=$(echo done/found/$1 | sed 's/compare\///g')
  			mkdir -p ${path}
			mv ${f} ${path}
  			break
  		else
  			mv ${f} done/compare
		fi
	done
}
# compare the frames
for d in $(find compare -type d | grep '/')
do
	compareFrames ${d} $1 &
done

# wait for comparisons to finish
while [ $(jobs -r | wc -l) -gt 0 ]
do
	continue
done
echo Done

# kill tail
kill $(jobs -p) >> /dev/null 2>> /dev/null