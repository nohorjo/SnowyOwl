#!/usr/bin/env python2

import sys
import cv2
import os

try:
    filename = sys.argv[1]
    frameDir = "compare/%s"% filename[filename.rfind("/")+1:]
    os.makedirs(frameDir)
except IndexError:
    print "Error: provide file"
    exit(1)
except OSError:
    pass

# load the video
vidcap = cv2.VideoCapture(filename)
# get the framerate
fps = vidcap.get(cv2.cv.CV_CAP_PROP_FPS)
count = 0
success = True
while True:
    # skip frames so that we get 1 frame every second
    for i in range(0, int(fps)):
        if not vidcap.grab():
            success = False
    if success:
        success, image = vidcap.retrieve()
        if success:
            # save frame as JPEG file
            cv2.imwrite("%s/%d.jpg" % (frameDir, count), image)
            count += 1
        else:
            break
    else:
        break
