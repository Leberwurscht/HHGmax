.. _ground-state-depletion:

Ground state depletion
======================

If the driving field intensity is very high, the target gas atoms get partially ionized over the time scale of one driving field pulse, i.e. the ground state is depleted, which affects the dipole response of the atom. Until now, all examples assumed zero ground state depletion, as is done in the Lewenstein et al. paper.

The implemented version of the Lewenstein model is extended to account for ground state depletion in a limited way - it cannot compute the ionization rate of the atoms from the driving field, but you can specify a file containing the rates so that the dipole response is corrected accordingly. This gives you the freedom to use ionization rates from more sophisticated atomic models than the one used by the Lewenstein model.

.. highlight:: matlab

To specify the file with the ionization rates, you add a option like the following to the `config` struct used for the :ref:`dipole_response` call::

   ...

   config.ionization_rate = 'ionization_rates.nc';

   ...

   [omega, response] = dipole_response(t_cmc, xv, yv, zv, config);

The specified file must be in NetCDF format and contain the time-dependent ionization rate for each grid point where you want to compute the dipole response. The file has to contain the following variables:

The **x** axis:
  The :math:`x` axis from the NetCDF file must be identical to the :math:`x` axis used as ``xv`` argument of the :ref:`dipole_response` call.

The **y** axis:
  The :math:`y` axis from the NetCDF file must be identical to the :math:`y` axis used as ``yv`` argument.

The **z** axis:
  Calls to :ref:`dipole_response` will fail if the ``zv`` argument contains values not in the :math:`z` axis of the NetCDF file.

The **t** axis:
  Must begin at :math:`0` and must be specified in scaled atomic units, i.e. one period corresponds to :math:`2\pi`. It does not need to be identical to the `t_cmc` argument as spline interpolation is used internally, so you can use a coarser time resolution to save disk space (100-200 time steps per driving field period are usually fine).

The ionization rate **W**:
  Must be a NetCDF variable with the dimensions ``z``, ``y``, ``x``, ``t`` (C-style order) containing the time-dependent ionization rates for the respective grid points, as obtained e.g. from the ADK model.

.. todo::
   symmetry

.. rubric:: Now, you know...

... how to compute dipole spectra of atoms accounting for ground state depletion.
