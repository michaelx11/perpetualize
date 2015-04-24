import numpy as np
import cv2
import matplotlib.pyplot as plt
from scipy.signal import argrelextrema
from scipy.optimize import curve_fit

from moviepy.editor import *

cap = cv2.VideoCapture('test_videos/boo.mov')
basedes = None
basekp = None
distTrack = []
videoFrames = []
distSum = 0

# for debugging
SHOW_VIDEO = False

# create BFMatcher object
bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)

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

      for i in kp1:
        cv2.circle(frame, (int(i.pt[0]), int(i.pt[1])), 3, (255, 255, 255), -1)

      if SHOW_VIDEO:
        cv2.imshow('frame', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    else:
      break

N = len(distTrack) # number of data points
t = np.linspace(0, 4*np.pi, N)
data = distTrack 

guess_freq = 1
guess_amplitude = 3*np.std(data)/(2**0.5)
guess_phase = 3.14159 * 3/2
guess_offset = np.mean(data)

p0=[guess_freq, guess_amplitude,
    guess_phase, guess_offset]

# create the function we want to fit
def my_sin(x, freq, amplitude, phase, offset):
    return np.sin(x * freq + phase) * amplitude + offset

# now do the fit
fit = curve_fit(my_sin, t, data, p0=p0)

# we'll use this to plot our first estimate. This might already be good enough for you
# data_first_guess = my_curve(t, *p0)

# recreate the fitted curve using the optimized parameters
data_fit = my_sin(t, *fit[0])

period = 1/(fit[0][0] / (2*np.pi))/(4*np.pi) * N
phase = fit[0][2]

print 'best matches for frames: '
print int(phase)
print int(phase+period)

# cv2.imshow('frame1', videoFrames[int(phase)])
# cv2.imshow('frame2', videoFrames[int(phase + period)])

## TESTING HOMOGRAPHY OF TWO FRAMES

hf1 = videoFrames[int(phase)]
hf2 = videoFrames[int(phase+period)]

# start = int(phase)
# end = int(phase+period)

## FIND SMALLEST DISTANCES BETWEEN TWO FRAMES OF PERIOD X APART

start = int(0)
end = int(period)
lowestDist = 999999
lowestPair = (0,period)

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
  for i in matches[:10]:
    distSum += i.distance

  if distSum < lowestDist:
    lowestPair = (start, end)
    lowestDist = distSum

  start += 1
  end += 1

start, end = lowestPair

finalVideo = videoFrames[start:end]
dimensions = finalVideo[0].shape[1], finalVideo[0].shape[0]
fourcc = cv2.cv.CV_FOURCC('m', 'p', '4', 'v')

vw = cv2.VideoWriter('testout.mp4', fourcc, 24, dimensions, True)

for i in finalVideo: 
  vw.write(i)

vw.release()
vw = None

cap.release()
cv2.destroyAllWindows()

clip = (VideoFileClip("testout.mp4"))
clip.write_gif("use_your_head.gif")


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

# plt.plot(data, '.')
# plt.plot(data_fit, label='after fitting')
# plt.show()

