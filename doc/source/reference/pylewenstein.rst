.. _pylewenstein:

pylewenstein.py
---------------

.. highlight:: python

Description
~~~~~~~~~~~

This module is not part of the Matlab/Octave framework.

It allows you to compute single atom dipole responses in Python by exposing a low-level interface to the Lewenstein model implemented in C++.

Overview
~~~~~~~~

The module provides three functions and one class, namely:

- :ref:`get_weights <pylewenstein-get-weights>` produces weights vectors used as argument to the ``lewenstein`` function.
- :ref:`sau_convert <pylewenstein-sau-convert>` converts between SI units and scaled atomic units.
- :ref:`lewenstein <pylewenstein-lewenstein>` computes dipole responses.
- :ref:`dipole_elements_H <pylewenstein-elements>` represents dipole elements derived from a hydrogen-like atomic potential.

.. _pylewenstein-lewenstein:

The ``lewenstein`` function
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``lewenstein`` function computes the time-dependent dipole vector given a time-dependent electric field vector, using the Lewenstein model. It supports 1-, 2- or 3-dimensional field vectors and accounts for ground state depletion. Its signature is

::

    def lewenstein(t,Et,ip,wavelength=None,weights=None,at=None,dipole_elements=None,epsilon_t=1e-4)

The return value ``d[C,t_i]`` is an array that contains the time-dependent dipole moment, where the first index gives the component of the dipole moment vector and the second index gives the time (corresponding to the argument t). The arguments are:

-  ``t`` is the time axis. The array must be equally spaced.

-  ``Et[C,t_i]`` is the time-dependent electric driving field. The first index gives the component of the electric
   field vector, so that you can pass elliptically polarized driving
   fields. The second index is for time (corresponding to the
   argument ``t``).

-  ``ip`` is the ionization potential :math:`I_p` of the used model atom.

-  ``wavelength`` (optional) is the wavelength of the driving field in SI units, i.e. meters. If omitted, all others arguments are assumed to be in scaled atomic units,
   and the return value is also in scaled atomic units. If provided, all other arguments and the return value are in SI units.

-  ``weights`` (optional) is a one-dimensional array specifying the
   window function :math:`w(\tau)` of the integral over :math:`\tau` in the Lewenstein formula.
   The corresponding :math:`\tau` axis is given by the ``t`` argument (shifted accordingly to start at zero). If the length of the weights
   vector is shorter than the ``t`` vector, the remaining values are assumed to be zero.
   If omitted, weights are generated that are one over one complete driving field period and then go softly to zero over half a driving field period, which includes both the short and the long trajectory.

-  ``at`` (optional) is a vector specifying the
   time-dependent ground state amplitude, which is used to account for
   ground state depletion. The vector must be of the same length as the ``t`` argument.
   If omitted, ground state depletion is neglected.

-  ``dipole_elements`` (optional) are the bound-continuum dipole matrix
   elements :math:`\vect D(\vect v)`. To get dipole matrix elements for a scaled
   hydrogen-like potential, use the ``dipole_elements_H`` class.
   If omitted, an instance of this class with appropriate value for ``ip`` is created on the fly.

-  ``epsilon_t`` (optional) is a small positive constant that
   is used to prevent the integral over :math:`\tau` in the Lewenstein formula from diverging at :math:`\tau=0`, in
   scaled atomic units (even if wavelength argument is provided). The default value is :math:`10^{-4}`.

.. _pylewenstein-get-weights:

The ``get_weights`` function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``get_weights`` function computes weight functions :math:`w(\tau)` which are :math:`1` over a certain :math:`\tau` interval and then go to zero following a :math:`\cos^2` function, for use as argument for the :ref:`lewenstein <pylewenstein-lewenstein>` function. Its signature is

::

    def get_weights(tau,T=2*np.pi,periods_one=1,periods_soft=.5)

The return value ``w[t_i]`` is an array of weights, where the index gives the time (corresponding to the argument t). Its length is in general shorter than the length of the ``tau`` argument. The arguments are:

-  ``tau`` is the :math:`\tau` axis. The array must be equally spaced, and you can use arbitrary units but must use the same unit as for the ``T`` argument.

-  ``T`` (optional) is the oscillation period of the driving field. If omitted, it is set to :math:`2\pi` (one period in scaled atomic units), so in this case the ``tau`` argument must also be in scaled atomic units.

-  ``periods_one`` is the length of the :math:`\tau` interval over which :math:`w(\tau)=1`, in driving field oscillation periods.

-  ``periods_soft`` is the length of the :math:`\tau` interval over which :math:`w(\tau)` follows a falling :math:`\cos^2` window, in driving field oscillation periods.

.. _pylewenstein-sau-convert:

The ``sau_convert`` function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``sau_convert`` function converts between SI and scaled atomic units. Its signature is::

    def sau_convert(value, quantity, target, wavelength)

The return value is the converted value. The arguments are:

-  ``value`` is the value that should be converted, in SI units if ``target=='SAU'`` or in scaled atomic units if ``target=='SI'``.

-  ``quantity`` is the physical quantity as a string. Supported values are ``'t'`` (time), ``'omega'`` (angular frequency), ``'U'`` (energy), ``'q'`` (charge), ``'s'`` (length), ``'E'`` (electric field), ``'d'`` (dipole moment), ``'m'`` (mass), and ``'p'`` (momentum).

-  ``target`` specifies the direction of the conversion. If ``target=='SAU'``, ``value`` is converted from SI units to scaled atomic units, if ``target=='SI'`` vice versa.

-  ``wavelength`` is the driving field wavelength in SI units, i.e. meters, which is needed for the conversion.

.. _pylewenstein-elements:

The ``dipole_elements_H`` class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``dipole_elements_H`` function represents dipole matrix elements derived from a hydrogen-like atomic potential. A instance of this class can be used as the ``dipole_elements`` argument of the :ref:`lewenstein <pylewenstein-lewenstein>` function. Its constructor's signature is::

    def __init__(self, dims, ip, wavelength=None)

The class does not expose any public methods or properties. The arguments of the constructor are:

-  ``dims`` is the number of dimensions of the electric field vector. Must be :math:`1`, :math:`2` or :math:`3`.

-  ``ip`` gives the ionization potential to which the atomic potential should be scaled.

-  ``wavelength`` (optional) is the wavelength of the driving field in SI units, i.e. meters. If omitted, the ``ip`` argument is assumed to be in scaled atomic units. If provided, it is assumed to be in SI units.
