import sys
import numpy as np
import cv2
import matplotlib.pyplot as plt
import norman_fit as sf
import random

import smoother

from moviepy.editor import *

TRANSITION_FRAMES = 3
DEBUG = False
INNAME = sys.argv[1]
timestamp = sys.argv[2]

if len(sys.argv) <= 1:
  print 'python process.py [input] [output] [optional: debug]'
  exit()

print 'processing video ... ', str(sys.argv[1])

if len(sys.argv) > 3:
  print 'DEBUG MODE' + str(sys.argv)
  DEBUG = True

cap = cv2.VideoCapture(INNAME)
basedes = None
basekp = None
distTrack = []
videoFrames = []
distSum = 0

# create BFMatcher object
bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)

def findUsingSimpleProcess(videoFrames):
  MIN_NUM_MATCHES = 50
  MIN_REQUIRED_DISTANCE = 8

  # create BFMatcher object
  bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
  orb = cv2.ORB()

  numFrames = len(videoFrames)
  lowestDist = 999999
  bestFrames = (0, numFrames-1)
  bestDesc = {}
  print 'Number of frames: ' + str(numFrames)
  for i in range(numFrames):
    if i < numFrames/2:
      kp1, des1 = orb.detectAndCompute(videoFrames[i], None)
      for j in range(numFrames - (i+1), numFrames):
        print 'Checking: ' + str((i, j))
        kp2, des2 = orb.detectAndCompute(videoFrames[j], None)
        matches = bf.match(des1,des2)
        matches = sorted(matches, key = lambda x:x.distance)
        if len(matches) > MIN_NUM_MATCHES:
          distSum = 0
          for k in matches[:10]:
            distSum += k.distance**2
          print 'distSum: ' + str(distSum)
          if distSum < lowestDist and abs(i-j) > MIN_REQUIRED_DISTANCE:
            lowestDist = distSum
            bestFrames = (i, j)
            bestDesc['m1'] = (kp1, des1)
            bestDesc['m2'] = (kp1, des1)
            bestDesc['numMatches'] = len(matches)
    else:
      break

  # print videoFrames
  start, end = bestFrames
  print bestDesc['numMatches']
  return (start, end)

# Match descriptors.
while(cap.isOpened()):
    ret, frame = cap.read()
    if frame != None:

      frame = cv2.resize(frame, (0,0), fx=0.3, fy=0.3)
      videoFrames.append(frame)
      # gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

      orb = cv2.ORB()
      kp1, des1 = orb.detectAndCompute(frame, None)

      if basedes == None: 
        basekp1 = kp1
        basedes = des1
      else:
        matches = bf.match(des1,basedes)
        matches = sorted(matches, key = lambda x:x.distance)

        prevDistSum = distSum
        distSum = 0
        for i in matches[:10]:
          distSum += i.distance
        if len(matches) < 10:
          distSum = prevDistSum

        # print distSum

        distTrack.append(distSum)
        # cv2.circle(frame, (10,10), int(distSum), (0, 255, 255), -1)

      if DEBUG:
        for i in kp1:
          cv2.circle(frame, (int(i.pt[0]), int(i.pt[1])), 3, (255, 255, 255), -1)

      # if SHOW_VIDEO:
      #   cv2.imshow('frame', frame)
      #   if cv2.waitKey(1) & 0xFF == ord('q'):
      #       break

    else:
      break

# N = len(distTrack) # number of data points
data = distTrack 

(data_fit, period, phase) = sf.sin_fit(data)

print data

print data_fit
print 'num frames'
print len(videoFrames)

print 'best matches for frames: '
print int(phase)
print int(phase+period)

# cv2.imshow('frame1', videoFrames[int(phase)])
# cv2.imshow('frame2', videoFrames[int(phase + period)])

## TESTING HOMOGRAPHY OF TWO FRAMES

# hf1 = videoFrames[int(phase)]
# hf2 = videoFrames[int(phase+period)]

# start = int(phase)
# end = int(phase+period)

## FIND SMALLEST DISTANCES BETWEEN TWO FRAMES OF PERIOD X APART

def findUsingSimpleProcess(videoFrames):
  MIN_NUM_MATCHES = 50
  MIN_REQUIRED_DISTANCE = 8

  # create BFMatcher object
  bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
  orb = cv2.ORB()

  numFrames = len(videoFrames)
  lowestDist = 999999
  bestFrames = (0, numFrames-1)
  bestDesc = {}
  print 'Number of frames: ' + str(numFrames)

  for i in range(numFrames):
    if i < numFrames/2:
      kp1, des1 = orb.detectAndCompute(videoFrames[i], None)
      for j in range(numFrames - (i+1), numFrames):
        print 'Checking: ' + str((i, j))
        kp2, des2 = orb.detectAndCompute(videoFrames[j], None)
        matches = bf.match(des1,des2)
        matches = sorted(matches, key = lambda x:x.distance)
        if len(matches) > MIN_NUM_MATCHES:
          distSum = 0
          for k in matches[:10]:
            distSum += k.distance**2
          print 'distSum: ' + str(distSum)
          if distSum < lowestDist and abs(i-j) > MIN_REQUIRED_DISTANCE:
            lowestDist = distSum
            bestFrames = (i, j)
            bestDesc['m1'] = (kp1, des1)
            bestDesc['m2'] = (kp1, des1)
            bestDesc['numMatches'] = len(matches)
    else:
      break

  # print videoFrames
  start, end = bestFrames
  print bestDesc['numMatches']
  return (start, end)


if period >= (len(videoFrames) * 0.75):
  start, end = findUsingSimpleProcess(videoFrames)
else:
  lowestDist = 999999
  lowestPair = (0,period)
  constantPeriod = period
  while period < len(videoFrames):
    start = int(0)
    end = int(period)
    while end < len(videoFrames):
      sFrame = videoFrames[start]
      eFrame = videoFrames[end]
        # gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

      orb = cv2.ORB()
      kp1, des1 = orb.detectAndCompute(sFrame, None)
      kp2, des2 = orb.detectAndCompute(eFrame, None)
      matches = bf.match(des1,des2)
      matches = sorted(matches, key = lambda x:x.distance)

      distSum = 0
      if len(matches) > 40:
        for i in matches[:40]:
          distSum += i.distance

        if distSum < lowestDist:
          lowestPair = (start, end)
          lowestDist = distSum

      start += 1
      end += 1
    period += constantPeriod


  start, end = lowestPair

numTransitionFrames = 0.05 * (end-start)
numTransitionFrames = int(max(min(numTransitionFrames, 15), 3))

trimVideo = videoFrames[start:(end+numTransitionFrames-1)]
finalVideo = smoother.smoothVideo(trimVideo, numTransitionFrames)

dimensions = finalVideo[0].shape[1], finalVideo[0].shape[0]
fourcc = cv2.cv.CV_FOURCC('m', 'p', '4', 'v')

vw = cv2.VideoWriter('uploads/' + timestamp + '/_.mp4', fourcc, 24, dimensions, True)

for i in finalVideo: 
  vw.write(i)

vw.release()
vw = None

cap.release()
cv2.destroyAllWindows()

baseDir = 'uploads/' + timestamp + '/'
clip = (VideoFileClip(baseDir + '_.mp4'))
clip.write_gif(baseDir + '_.gif')

cv2.imwrite(baseDir + 'thumbnail.png', finalVideo[random.randint(0,int(end-start-2))], (cv2.cv.CV_IMWRITE_PNG_COMPRESSION, 8))

# sift = cv2.SIFT()

# kp1, des1 = sift.detectAndCompute(hf1,None)
# kp2, des2 = sift.detectAndCompute(hf2,None)

# FLANN_INDEX_KDTREE = 0
# index_params = dict(algorithm = FLANN_INDEX_KDTREE, trees = 5)
# search_params = dict(checks = 50)

# flann = cv2.FlannBasedMatcher(index_params, search_params)
# matches = flann.knnMatch(des1,des2,k=2)

# # store all the good matches as per Lowe's ratio test.
# good = []
# for m,n in matches:
#     if m.distance < 0.7*n.distance:
#         good.append(m)
# MIN_MATCH_COUNT = 10

# if len(good)>MIN_MATCH_COUNT:
#     src_pts = np.float32([ kp1[m.queryIdx].pt for m in good ]).reshape(-1,1,2)
#     dst_pts = np.float32([ kp2[m.trainIdx].pt for m in good ]).reshape(-1,1,2)

#     print 'srouce', src_pts
#     print 'dest', dst_pts

#     M, mask = cv2.findHomography(src_pts, dst_pts, cv2.RANSAC,5.0)
#     matchesMask = mask.ravel().tolist()

#     print 'M', M
#     print 'mask', mask

#     h,w,c = hf1.shape
#     # pts = np.float32([ [0,0],[0,h-1],[w-1,h-1],[w-1,0] ]).reshape(-1,1,2)
#     # dst = cv2.perspectiveTransform(pts,M)

#     # hf2 = cv2.polylines(hf2,[np.int32(dst)],True,255,3)

# # print 'DST', dst

# #hf1 = cv2.warpPerspective(hf1, M, (h,w))
# # hf2 = cv2.warpPerspective(hf2, cv2.invert(M), (w,h))
# cv2.imshow('frame1', hf1)
# cv2.imshow('frame2', hf2)

# # cv2.imshow('frame2', hf2)

if DEBUG:
  print data

  plt.plot(data, '.')
  plt.plot(data_fit, label='after fitting')
  plt.show()


# If the period is too large, revert to using the simple method of finding matches
# TODO: convert this to simple image matching





