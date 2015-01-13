.. _lewenstein:

lewenstein
----------

Description
~~~~~~~~~~~

Unlike the other modules, the Lewenstein model is implemented in C++
(``lewenstein.hpp``). The file ``hhgmax_lewenstein.cpp`` provides the Matlab
(or Octave) interface to this C++ code and must be compiled to a
``.mex`` file in order to be usable from within Matlab/Octave (see :ref:`compilation`).
It computes the time-dependent single-atom
dipole response from a given driving field :math:`\vect E(t)` and is
able to deal with elliptically polarized fields.

This module is rather low-lewel, so you might prefer to use the
:ref:`dipole_response` module which has a more convenient interface and
calls this module for you.

Arguments and Return Values
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The signature of the ``farfield`` function is

::

    dt = hhgmax.lewenstein(t, Et, config);
        

The return value ``dt(C,t_i)`` is an array that contains the
time-dependent dipole moment in scaled atomic units, where the first
index gives the component of the dipole moment vector and the second
index gives the time (corresponding to the argument ``t``). The
arguments are:

-  ``t`` is the time axis in scaled atomic units, i.e. a value of
   :math:`2\pi` corresponds to one driving field period. The array must
   be equally spaced and start at :math:`0`.

-  ``Et(C,t_i)`` is the time-dependent electric driving field in scaled
   atomic units. The first index gives the component of the electric
   field vector, so that you can pass elliptically polarized driving
   fields. The second index gives the time (corresponding to the
   argument ``t``).

-  ``config`` is a ``struct()`` of the following fields:

   -  ``config.ip`` is the ionization potential :math:`I_p` of the used
      model atom in scaled atomic units.

   -  ``config.epsilon_t`` (optional) is a small positive constant that
      is used to prevent the integral over :math:`\tau` in the Lewenstein formula from diverging at :math:`\tau=0`, in
      scaled atomic units. The default value is :math:`10^{-4}`.

   -  ``config.weights`` is a one-dimensional array specifying the
      window function :math:`w(\tau)` of the integral over :math:`\tau` in the Lewenstein formula.
      The corresponding :math:`\tau` axis is given by the ``t`` argument. If the length of the weights
      vector is shorter than the ``t`` vector, the remaining values are assumed to be zero.

   -  ``config.ground_state_amplitude`` is a vector specifying the
      time-dependent ground state amplitude, which is used to account for
      ground state depletion. The vector must be of the same length as the ``t`` argument.
      For no ground state depletion, you can set this to ``ones(1,length(t))``.

   -  ``config.dipole_method`` (optional) specifies which method
      should be used to compute the bound-continuum dipole matrix
      elements :math:`\vect D(\vect v)`. Currently, ``'H'`` (default)
      and ``'symmetric_interpolate'`` are supported.

      The former uses dipole matrix elements for a scaled
      hydrogen-like potential. When this method is used,
      you can specify the depth of the potential in units of :math:`I_p`
      using the optional ``config.alpha`` argument.

      The latter allows you to pass arbitrary spherically symmetric
      functions
      :math:`\vect D(\vect v) = \tilde{D}(|\vect v|) \cdot \hat{\vect v}`
      by providing an array :math:`\tilde{D}(v_i)` in which
      :math:`\tilde{D}(|\vect v|)` is interpolated. The :math:`v_i` axis
      is assumed to be equally spaced and to start at zero, and the
      spacing must be given by the ``config.deltav`` argument. The array
      :math:`\tilde{D}(v_i)` must be specified with the
      ``config.dipole_elements`` argument. Both arguments are in scaled
      atomic units. Note that in the Lewenstein model, the dipole
      spectra are very sensitive to the dipole matrix elements. As
      linear interpolation is used, you need to make sure to use a
      sufficiently fine discretization to avoid artifacts.
