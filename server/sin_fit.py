from scipy.optimize import curve_fit
import numpy as np

def sin_fit(data):  
  N = len(data)
  t = np.linspace(0, 4*np.pi, N)

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

  return data_fit, period, phase