#!/usr/bin/env python

# add framework path to Python's search path
import os, sys
hhgmax_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','..','..') # you need to adapt this!
sys.path.append(hhgmax_dir)

# import the pylewenstein module and numpy
import pylewenstein
import numpy as np

# set parameters (everything is SI units)
wavelength = 1000e-9 # 1000 nm
fwhm = 30e-15 # 30 fs
ionization_potential = 12.13*pylewenstein.e # 12.13 eV (Xe)
peakintensity = 1e14 * 1e4 # 1e14 W/cm^2

# define time axis
T = wavelength/pylewenstein.c # one period of carrier
t = np.linspace(-20.*T,20.*T,200*40+1)

# define electric field: Gaussian with given peak intensity, FWHM and a cos carrier
tau = fwhm/2./np.sqrt(np.log(np.sqrt(2)))
Et = np.exp(-(t/tau)**2) * np.cos(2*np.pi/T*t) * np.sqrt(2*peakintensity/pylewenstein.c/pylewenstein.eps0)

# use module to calculate dipole response (returns dipole moment in SI units)
d = pylewenstein.lewenstein(t,Et,ionization_potential,wavelength)

# plot result
import pylab

pylab.figure(figsize=(5,4))
q = np.fft.fftfreq(len(t), t[1]-t[0])/(1./T)
pylab.semilogy(q[q>=0], abs(np.fft.fft(d)[q>=0])**2)
pylab.xlim((0,100))
pylab.show()
