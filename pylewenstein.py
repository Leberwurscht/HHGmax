from __future__ import division

import ctypes, os, shutil
import numpy as np

# constants
c = 299792458
eps0 = 8.854187817e-12
e = 1.602176565e-19
m_e = 9.10938291e-31
hbar = 1.054571726e-34
h = 2*np.pi*hbar
a0 = 4*np.pi*eps0*hbar**2/m_e/e**2
Ry = h*c * m_e*e**4/8/eps0**2/h**3/c

# find and import shared object / DLL
rootdir = os.path.dirname(os.path.realpath(__file__))

if os.name=="posix":
  lewenstein_so = ctypes.CDLL(os.path.join(rootdir,'lewenstein.so'))
elif os.name=="nt":
  bits = ctypes.sizeof(ctypes.c_voidp)*8
  archdirectory = os.path.join(rootdir,'dll' + str(bits))

  cwd = os.getcwd()
  os.chdir(archdirectory) # necessary to load dependencies correctly
  lewenstein_so = ctypes.CDLL('lewenstein.dll')
  os.chdir(cwd)

# Note: explicitly setting lewenstein_so.*.argtypes/restype is necessary to prevent segfault on 64 bit:
# http://stackoverflow.com/questions/17240621/wrapping-simple-c-example-with-ctypes-segmentation-fault

# base class for dipole elements
class dipole_elements(object):
  dims = None
  pointer = None

  def __del__(self):
    raise NotImplementedError('override in subclasses')

# wrap H dipole elements
lewenstein_so.dipole_elements_H_double.argtypes = [ctypes.c_int, ctypes.c_double]
lewenstein_so.dipole_elements_H_double.restype = ctypes.c_void_p
lewenstein_so.dipole_elements_H_double_destroy.argtypes = [ctypes.c_int, ctypes.c_void_p]
lewenstein_so.dipole_elements_H_double_destroy.restype = None

class dipole_elements_H(dipole_elements):
  def __init__(self, dims, ip, wavelength=None):
    if wavelength:
      ip = sau_convert(ip, 'U', 'SAU', wavelength)

    alpha = 2*ip

    self.dims = dims
    self.pointer = lewenstein_so.dipole_elements_H_double(dims, alpha)

  def __del__(self):
    lewenstein_so.dipole_elements_H_double_destroy(self.dims, self.pointer)

# wrap symmetric interpolated dipole elements
lewenstein_so.dipole_elements_symmetric_interpolate_double.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_double, ctypes.c_void_p, ctypes.c_void_p]
lewenstein_so.dipole_elements_symmetric_interpolate_double.restype = ctypes.c_void_p
lewenstein_so.dipole_elements_symmetric_interpolate_double_destroy.argtypes = [ctypes.c_int, ctypes.c_void_p]
lewenstein_so.dipole_elements_symmetric_interpolate_double_destroy.restype = None

class dipole_elements_symmetric_interpolate(dipole_elements):
  _dr = None
  _di = None

  def __init__(self, dims, p, d, wavelength=None):
     if wavelength is not None:
       p = sau_convert(p, 'p', 'SAU', wavelength)
       d = sau_convert(d, 'd', 'SAU', wavelength)

     self.dims = dims

     N = p.size
     assert d.size==N

     dp = np.min(np.diff(p))
     assert np.isclose(dp, np.max(np.diff(p)), atol=0)

     # dr and di must not be garbage collected until destructor is called, so make it a property of this class
     self._dr = np.require(np.copy(d.real), np.double, ['C', 'A'])
     self._di = np.require(np.copy(d.imag), np.double, ['C', 'A'])

     self.pointer = lewenstein_so.dipole_elements_symmetric_interpolate_double(dims, N, dp, self._dr.ctypes.data, self._di.ctypes.data)

  def __del__(self):
     lewenstein_so.dipole_elements_symmetric_interpolate_double_destroy(self.dims, self.pointer)

# helper function to generate weights
def get_weights(tau,T=2*np.pi,periods_one=1,periods_soft=.5):
  interval_points = sum(tau-tau[0]<=periods_one*T)
  window_points = sum(tau-tau[0]<=periods_soft*T)

  r = np.ones(interval_points+window_points)
  r[-window_points:] = np.cos(np.pi/2 * np.arange(window_points)/window_points)**2

  return r

# helper function for unit conversion
def sau_convert(value, quantity, target, wavelength):
  # scaled atomic unit quantities expressed in SI units
  unit = {}
  unit['t'] = wavelength / c / (2*np.pi)
  unit['omega'] = 1/unit['t']
  unit['U'] = hbar * unit['omega'] # hbar*omega
  unit['q'] = e
  unit['s'] = a0 * np.sqrt(2*Ry/unit['U']) # [concluded from (23) in Lewenstein paper]
  unit['E'] = unit['U'] / unit['q'] / unit['s'] # [concluded from (2) in Lewenstein paper]
  unit['d'] = unit['q'] * unit['s'] # dipole element
  unit['m'] = m_e
  unit['p'] = unit['m'] * unit['s']/unit['t'] # momentum

  if target=="SI":
    return value * unit[quantity]
  elif target=="SAU":
    return value / unit[quantity]
  else:
    raise ValueError('target must be SI or SAU')

# wrap lewenstein function
lewenstein_so.lewenstein_double.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_double, ctypes.c_double, ctypes.c_void_p, ctypes.c_void_p]
lewenstein_so.lewenstein_double.restype = None

def lewenstein(t,Et,ip,wavelength=None,weights=None,at=None,dipole_elements=None,epsilon_t=1e-4):
  # default value for weights
  if weights is None and wavelength is None:
    weights = get_weights(t)
  elif weights is None and wavelength is not None:
    weights = get_weights(t, wavelength/c)

  # unit conversion
  if wavelength is not None:
    t = sau_convert(t, 't', 'SAU', wavelength)
    Et = sau_convert(Et, 'E', 'SAU', wavelength)
    ip = sau_convert(ip, 'U', 'SAU', wavelength)

  # default value for ground state amplitude
  if at is None: at = np.ones_like(t)

  # allocate memory for output
  output = np.empty_like(Et)

  # make sure t axis starts at zero
  t = t - t[0]

  # make sure we have appropriate memory layout before passing to C code
  t = np.require(t, np.double, ['C', 'A'])
  Et = np.require(Et, np.double, ['C', 'A'])
  weights = np.require(weights, np.double, ['C', 'A'])
  at = np.require(at, np.double, ['C', 'A'])
  output = np.require(output, np.double, ['C', 'A', 'W'])

  # get dimensions
  N = t.size
  dims = Et.shape[1] if len(Et.shape)>1 else 1
  weights_length = weights.size

  # check dimensions
  assert at.size==N
  assert Et.shape[0]==N
  assert dims in [1,2,3]
  assert Et.size==N*dims

  # default value for dipole elements
  if dipole_elements is None: dipole_elements = dipole_elements_H(dims, ip=ip)

  # call C function
  assert dipole_elements.dims==dims
  lewenstein_so.lewenstein_double(dims, N, t.ctypes.data, Et.ctypes.data, weights_length, weights.ctypes.data, at.ctypes.data, ip, epsilon_t, dipole_elements.pointer, output.ctypes.data)

  # unit conversion
  if wavelength is not None:
    output = sau_convert(output, 'd', 'SI', wavelength)

  return output

# wrap yakovlev function
lewenstein_so.yakovlev_double.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_double, ctypes.c_int, ctypes.c_int, ctypes.c_void_p]
lewenstein_so.yakovlev_double.restype = None

def yakovlev(t,Et,ip,at,wavelength=None,trajectories=2,skip_trajectories=0,max_periods=2,tb_window=None):
  # unit conversion
  if wavelength is not None:
    t = sau_convert(t, 't', 'SAU', wavelength)
    Et = sau_convert(Et, 'E', 'SAU', wavelength)
    ip = sau_convert(ip, 'U', 'SAU', wavelength)

  # default value for tb window
  if tb_window is None: tb_window = np.ones_like(t)

  # allocate memory for output
  output = np.empty_like(Et)

  # make sure t axis starts at zero
  t = t - t[0]

  # replace infinite max_periods by sensible value
  if max_periods is None or not np.isfinite(max_periods): max_periods = np.max(t)/2/np.pi + 1

  # make sure we have appropriate memory layout before passing to C code
  t = np.require(t, np.double, ['C', 'A'])
  Et = np.require(Et, np.double, ['C', 'A'])
  at = np.require(at, np.double, ['C', 'A'])
  tb_window = np.require(tb_window, np.double, ['C', 'A'])
  output = np.require(output, np.double, ['C', 'A', 'W'])

  # get dimensions
  N = t.size
  dims = Et.shape[1] if len(Et.shape)>1 else 1
  max_tau_i = np.where(t<2*np.pi*max_periods)[0][-1]

  # check dimensions
  assert at.size==N
  assert tb_window.size==N
  assert Et.shape[0]==N
  assert dims==1
  assert Et.size==N*dims

  # call C function
  lewenstein_so.yakovlev_double(dims, N, t.ctypes.data, Et.ctypes.data, max_tau_i, at.ctypes.data, tb_window.ctypes.data, ip, int(trajectories), int(skip_trajectories), output.ctypes.data)

  # unit conversion
  if wavelength is not None:
    output = sau_convert(output, 'd', 'SI', wavelength)

  return output

def cutoff(amplitude,ip,wavelength):
  """ expects SI units """

  # unit conversion
  amplitude = sau_convert(amplitude, 'E', 'SAU', wavelength)
  ip = sau_convert(ip, 'U', 'SAU', wavelength)
  omega = 2*np.pi/sau_convert(wavelength/c, 't', 'SAU', wavelength)

  up = amplitude**2/4/omega**2
  harmonic_order = ip + 3.17*up

  return harmonic_order

def cutoff_amplitude(harmonic_order,ip,wavelength):
  """ expects SI units """

  # unit conversion
  ip = sau_convert(ip, 'U', 'SAU', wavelength)
  omega = 2*np.pi/sau_convert(wavelength/c, 't', 'SAU', wavelength)

  up = (harmonic_order - ip)/3.17
  amplitude = np.sqrt(4*omega**2*up)
  amplitude = sau_convert(amplitude, 'E', 'SI', wavelength)

  return amplitude

if __name__=="__main__":
  import pylab

  # compare to reference, in scaled atomic units
  n = 5

  t = np.arange(n)
  Et = t
  weights = np.ones_like(t)
  ip = 1

  d = lewenstein(t,Et,ip,None,weights)
  reference_d = [0.00000, 0.00000, -2.18318, -2.95464, -1.23753] # computed by Matlab/octave module
  assert np.allclose(d, reference_d, atol=1e-4)
  print "Test passed"

  # plot dipole response for pulse (using SI units)
  wavelength = 1000e-9
  T = wavelength/c
  t = np.linspace(-20*T,20*T,200*40+1)

  fwhm = 30e-15
  tau = fwhm/2/np.sqrt(np.log(np.sqrt(2)))
  Et = np.exp(-(t/tau)**2) * np.cos(2*np.pi/T*t) * np.sqrt(2*1e18/c/eps0)

  ip = 12.13*e # Xe

  d = lewenstein(t,Et,ip,wavelength)

  Dp = np.arange(0,10,1e-4)
  alpha = 2*sau_convert(ip,'U','SAU',wavelength)
  Dd = 1j*(2**(7/2)*alpha**(5/4)/np.pi) * Dp / (Dp**2+alpha)**3
  dint = dipole_elements_symmetric_interpolate(1, Dp, Dd)
  d2 = lewenstein(t,Et,ip,wavelength,dipole_elements=dint)

  pylab.semilogy(np.fft.fftfreq(len(t), t[1]-t[0])/(1/T), abs(np.fft.fft(d))**2)
  pylab.semilogy(np.fft.fftfreq(len(t), t[1]-t[0])/(1/T), abs(np.fft.fft(d2))**2, label='interpolated d')
  pylab.legend()
  pylab.xlim((0,100))
  pylab.show()
