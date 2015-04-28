import numpy as np
import cv2


# a b c d e f g
# for p = 2
# a/f    b/g     c d e 
# 33/66  66/33
# for p = 3
# ae    bf    cg d ea fb gc
# 57/43 71/29 86/14

def smoothVideo(video, p):
  outputVideo = np.array(video).copy()
  d = 1.0/(p+1)
  w = d
  for i in range(p):
    print i, w
    v1, v2 = transformFrames(video[i], video[-(p-i)], w)
    outputVideo[i] = v1*w + v2*(1-w)
    # transformFrames(video[i], video[-(p-i)], 0.5)
    w += d
  return outputVideo[:-p]

cap = cv2.VideoCapture('uploads/Uz5WLA2/_.mp4')
f = []
while(cap.isOpened()):
  ret, frame = cap.read()
  if frame == None:
    break
  f.append(frame)

# http://www.pyimagesearch.com/2014/08/25/4-point-opencv-getperspective-transform-example/

def transformFrames(f1, f2, w):

  # cv2.imshow('warped', f1)
  # cv2.imshow('paritalwarped', f2)
  
  # while True:
  #   if cv2.waitKey(1) & 0xFF == ord('q'):
  #     break

  sift = cv2.SIFT()
  # find the keypoints and descriptors with SIFT
  kp1, des1 = sift.detectAndCompute(f1,None)
  kp2, des2 = sift.detectAndCompute(f2,None)

  FLANN_INDEX_KDTREE = 0
  index_params = dict(algorithm = FLANN_INDEX_KDTREE, trees = 5)
  search_params = dict(checks = 50)

  flann = cv2.FlannBasedMatcher(index_params, search_params)
  matches = flann.knnMatch(des1,des2,k=2)

  # store all the good matches as per Lowe's ratio test.
  good = []
  for m,n in matches:
      if m.distance < 0.7*n.distance:
          good.append(m)

  src_pts = np.float32([ kp1[m.queryIdx].pt for m in good ]).reshape(-1,1,2)
  dst_pts = np.float32([ kp2[m.trainIdx].pt for m in good ]).reshape(-1,1,2)

  M, mask = cv2.findHomography(src_pts, dst_pts, cv2.RANSAC,5.0)
  Mp, mask2 = cv2.findHomography(dst_pts, src_pts, cv2.RANSAC,5.0)
  matchesMask = mask.ravel().tolist()
  h,wi,c = f1.shape

  # this bit of logic I need to figure out why I needed to add it
  # it works, I have no idea why
  w = 1-w
  
  weighted = np.array([1,w,w,w,1,w,1,1,1]).reshape((3,3))
  M = np.multiply(M, weighted)
  warped = cv2.warpPerspective(f1, M, (wi, h))

  wp = 1-w
  weightedp = np.array([1,wp,wp,wp,1,wp,1,1,1]).reshape((3,3))
  Mp = np.multiply(Mp, weightedp)
  pwarped = cv2.warpPerspective(f2, Mp, (wi, h))

  # cv2.imshow('warped', warped)
  # cv2.imshow('paritalwarped', pwarped)

  # while True:
  #   if cv2.waitKey(1) & 0xFF == ord('q'):
  #     break

  return warped, pwarped

    # N = np.multiply(M, half)


    # print M
    # # print N

    # # pts = np.float32([ [0,0],[0,h-1],[w-1,h-1],[w-1,0] ]).reshape(-1,1,2)
    # # dst = cv2.perspectiveTransform(pts,M)

    # # print dst

    # while True:
    #   cv2.imshow('frame', f1)
    #   cv2.imshow('frame2', f2)
    #   cv2.imshow('warped', warped)
    #   cv2.imshow('paritalwarped', pwarped)
    #   if cv2.waitKey(1) & 0xFF == ord('q'):
    #       break


# finalVideo = smoothVideo(np.array(f), 10)
# dimensions = finalVideo[0].shape[1], finalVideo[0].shape[0]
# fourcc = cv2.cv.CV_FOURCC('m', 'p', '4', 'v')
# vw = cv2.VideoWriter('uploads/Uz5WLA2/sv.mp4', fourcc, 24, dimensions, True)
# for i in finalVideo: 
#   vw.write(i)

# vw.release()
# vw = None