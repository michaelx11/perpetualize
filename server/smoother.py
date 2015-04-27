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
    outputVideo[i] = video[i]*w + video[-(p-i)]*(1-w)
    w += d
  return outputVideo[:-p]

# cap = cv2.VideoCapture('uploads/Uz5WLA2/_.mp4')
# f = []
# while(cap.isOpened()):
#   ret, frame = cap.read()
#   if frame == None:
#     break
#   f.append(frame)


# finalVideo = smoothVideo(np.array(f), 4)
# dimensions = finalVideo[0].shape[1], finalVideo[0].shape[0]
# fourcc = cv2.cv.CV_FOURCC('m', 'p', '4', 'v')
# vw = cv2.VideoWriter('uploads/Uz5WLA2/sv.mp4', fourcc, 24, dimensions, True)
# for i in finalVideo: 
#   vw.write(i)

# vw.release()
# vw = None