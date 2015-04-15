.. _ground-state-depletion:

Ground state depletion
======================

If the driving field intensity is very high, the target gas atoms get partially ionized over the time scale of one driving field pulse, i.e. the ground state is depleted, which affects the dipole response of the atom. Until now, all examples assumed zero ground state depletion, as is done in the Lewenstein et al. paper.

The implemented version of the Lewenstein model is extended to account for ground state depletion in a limited way - it cannot compute the ionization rate of the atoms from the driving field, but you can specify a callback function doing so or provide static, i.e. intensity-dependent ionization rates which are used to compute the time-dependend ionization rate. This gives you the freedom to use ionization rates from more sophisticated atomic models than the one used by the Lewenstein model.

.. highlight:: matlab

Static ionization rates
-----------------------

The :ref:`dipole_response` module can also compute the time-dependent ionization by itself under the quasi-static approximation if you provide the static ionization rates, which
can be obtained e.g. from the included module :ref:`tong_lin_ionization_rate`. For this, use the ``static_ionization_rate`` option on the ``config`` struct of the :ref:`dipole_response` call, together with an intensity axis provided by the ``static_ionization_rate_field``
option:

.. literalinclude:: ../../../examples/tutorial/ground_state_depletion/static_rates.m
   :language: matlab
   :lines: 41-48

Provide a callback function
---------------------------

To provide a callback function that computes the time-dependent ionization fraction, use the ``ionization_fraction`` option on the ``config`` struct of the :ref:`dipole_response` call::

   ...

   config.ionization_fraction = 'my_callback_file';

   ...


   [omega, response] = hhgmax.dipole_response(t_cmc, xv, yv, zv, config);

Then, create a function called ``my_callback_file.m`` which looks like this::

   function ionization_fraction = my_callback_file(t_SAU, Et_SAU, config)

   % load HHGmax to be able to access sau_convert
   hhgmax = hhgmax_load();

   % convert from scaled atomic units
   t_fs = hhgmax.sau_convert(t_cmc, 't', 'SI', config) / 1e-15;
   Et_SI = hhgmax.sau_convert(Et_SAU, 'E', 'SI', config);

   % compute time-dependent ionization fraction eta(t) given E(t)
   % ...

   % set return value
   ionization_fraction = eta;

.. rubric:: Now, you know...

... how to compute dipole spectra of atoms accounting for ground state depletion.
