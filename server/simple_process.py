# SIMPLE PROCESS
# using simple matching techniques, check to see when two frames are similar

import sys
import numpy as np
import cv2
import matplotlib.pyplot as plt
import sin_fit as sf
from moviepy.editor import *

if len(sys.argv) <= 1:
  print 'python process.py [input] [output] [optional: debug]'
  exit()

print 'processing video ... ', str(sys.argv[1])

INNAME = sys.argv[1]
OUTNAME = sys.argv[2]

if len(sys.argv) > 2:
  print 'DEBUG MODE' + str(sys.argv)
  DEBUG = True

MIN_NUM_MATCHES = 50
MIN_REQUIRED_DISTANCE = 8

cap = cv2.VideoCapture(INNAME)

def norm(data):
  # get JPG image as Scipy array, RGB (3 layer)
  # convert to grey-scale using W3C luminance calc
  data = sp.inner(data, [299, 587, 114]) / 1000.0
  # normalize per http://en.wikipedia.org/wiki/Cross-correlation
  return (data - data.mean()) / data.std()

# create BFMatcher object
bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
orb = cv2.ORB()

videoFrames = []

while(cap.isOpened()):
    ret, frame = cap.read()
    if frame != None:
      frame = cv2.resize(frame, (0,0), fx=0.3, fy=0.3)
      videoFrames.append(frame)
    else:
      break

numFrames = len(videoFrames)
lowestDist = 999999
bestFrames = (0, numFrames-1)
bestDesc = {}
print 'Number of frames: ' + str(numFrames)
for i in range(numFrames):
  if i < numFrames/2:
    # kp1, des1 = orb.detectAndCompute(videoFrames[i], None)
    for j in range(numFrames - (i+1), numFrames):
      print 'Checking: ' + str((i, j))


      if distSum < lowestDist:
        lowestDist = distSum
        bestFrames = (i, j)

  else:
    break

# print videoFrames
start, end = bestFrames

print (start, end)

finalVideo = videoFrames[start:end]
dimensions = finalVideo[0].shape[1], finalVideo[0].shape[0]
fourcc = cv2.cv.CV_FOURCC('m', 'p', '4', 'v')

vw = cv2.VideoWriter('testout.mp4', fourcc, 24, dimensions, True)

for i in finalVideo: 
  vw.write(i)

vw.release()
vw = None

while True:
  if DEBUG:
    cv2.imshow('f1', f1)
    cv2.imshow('f2', f2)
    if cv2.waitKey(1) & 0xFF == ord('q'):
      break

cap.release()
cv2.destroyAllWindows()

clip = (VideoFileClip("testout.mp4"))
clip.write_gif(OUTNAME)



