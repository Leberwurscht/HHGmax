import os, sys
directory = os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','..','..','examples','tutorial','python')
print directory
sys.path.append(directory)

import pylab
import numpy as np

def nop(): pass
pylab.show = nop

import dipole_spectrum

pylab.savefig('python_pulses.png')
