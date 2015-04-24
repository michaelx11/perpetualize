from scipy.optimize import curve_fit
import numpy as np

def sin_fit(data):  
  N = len(data)

  def sinfunc(x,a,b):
    return a*np.sin(x-b)
  x = np.linspace(0, 4*np.pi, N)
  fitpars, covmat = curve_fit(sinfunc,x,data)


  data_fit = sinfunc(x, *fitpars)
  period = abs(1/(fitpars[0] / (2*np.pi))/(4*np.pi) * N)
  phase = 10
  
  return data_fit, period, phase