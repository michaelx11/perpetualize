import numpy as np
import scipy.optimize as optimize
import scipy.fftpack as fftpack
import matplotlib.pyplot as plt

pi = np.pi
plt.figure(figsize = (15, 5))

def sin_fit(data):  
  # generate a perfect data set (my real data have tiny error)
  print data

  def mysine(x, a1, a2, a3):
      return a1 * np.sin(a2 * x + a3)


  # xmax = 10
  # xReal = np.linspace(0, xmax, N)
  # a1 = 200.
  # a2 = 2*pi/10.5  # omega, 10.5 is the period
  # a3 = np.deg2rad(10.) # 10 degree phase offset
  # print(a1, a2, a3)
  # data = mysine(xReal, a1, a2, a3) + 0.2*np.random.normal(size=len(xReal))

  xReal = np.linspace(0, len(data), len(data))  
  N = len(data)

  yhat = fftpack.rfft(data)
  idx = (yhat[1:]**2).argmax() + 1
  freqs = fftpack.rfftfreq(N, d = (xReal[1]-xReal[0])/(2*pi))
  frequency = freqs[idx]

  amplitude = max(data)
  guess = [amplitude, frequency, 0.]
  # print(guess)
  (amplitude, frequency, phase), pcov = optimize.curve_fit(
      mysine, xReal, data, guess)

  period = 2*pi/frequency
  # print(amplitude, frequency, phase)

  print period

  phase = 0
  data_fit = mysine(xReal, amplitude, frequency, phase)
  return data_fit, period, phase
