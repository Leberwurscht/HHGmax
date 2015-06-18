.. _resources:

Dealing with Memory and CPU Restrictions
========================================

.. highlight:: matlab

Depending on the simulation parameters, the computation can be very demanding for standard PC hardware. One issue are the RAM requirements. If you call the :ref:`dipole_response` module directly, for each point of the discretized interaction volume one dipole spectrum must be stored. In general, you can compute the amount of RAM you need with the following formula (in MB)::

  length(xv) * length(yv) * length(zv) * length(t_cmc)/2 * 8*2 / 1000 / 1000

To compute with elliptical polarization, you need twice as much RAM.

If you do not directly call the :ref:`dipole_response` module, but use the :ref:`harmonic_propagation` module, only one :math:`z` slice must be kept in RAM at a time. So you can compute the RAM requirements with this formula (again in MB)::

  length(xv) * length(yv) * length(t_cmc)/2 * 8*2 / 1000 / 1000

.. rubric:: Use Cache

The computation of the dipole responses can take a long time. Sometimes, you only want to play with parameters affecting harmonic propagation or far field computation so it makes sense to reuse already computed dipole responses. To do this, an on-disk cache functionality is available which can be activated by setting a cache directory::

  config.cache.directory = 'cache/';

If you set this, computed dipole spectra will be saved in the specified directory. If you call your program again, it will be checked if the parameters have changed, and if they haven't, the saved spectra will be used.

..
   The previous adjustment will only reduce RAM requirements. Another issue is the computation time. Often, it is necessary to only adapt some parameters e.g. for the :ref:`harmonic_propagation` module or the :ref:`farfield` module, but you do not want to recompute the already computed dipole spectra, as this is very time-consuming. To avoid this, you can use the built-in cache functionality of the :ref:`dipole_response` module, which can be activated by the ``cachedir`` configuration option, e.g.::

.. rubric:: Control RAM Usage

Often, the dipole responses consume a great amount of RAM which can lead to serious performance problems due to swapping or to out of memory errors. If you use the on-disk cache described above, computed dipole responses are saved to disk immediately and do not need to be kept in RAM. Then you can instruct the :ref:`dipole_response` module to only return a part of the full frequency spectrum to avoid loading large amounts of data in the RAM. To do this, add the return_omega argument to calls of :ref:`dipole_response` or :ref:`harmonic_propagation`, e.g. to get the spectrum from 13th to 19th harmonic::

   return_omega = [13 19];

   [omega, response_cmc] = hhgmax.dipole_response(t_cmc, xv, yv, zv, config, [], return_omega);
   % or:
   [z_max,omega,U] = hhgmax.harmonic_propagation(t_cmc, xv, yv, zv, dipole_response_config, config, return_omega);

.. note::
   When using the on-disk cache, a transpose operation has to be performed to reduce inperformant non-sequential access to hard drives later. The amount of RAM used for this defaults to 1GB, but you can configure it using the config.cache.transpose_RAM option (value in GB). Smaller values slow down the operation.

..
  If this is too much, you can instruct the program to keep the dipole responses on a on-disk cache instead of in the RAM. 
  only keep only a part of the computed spectrum and discard the rest. For this, you set the ``cache_omega_ranges`` option on the configuration ``struct()`` of the dipole reponse module, e.g.
..
  ::
..
    config.cache_omega_ranges = [14.9 15.1; 16.9 17.1; 18.9 19.1];
..
  which will only keep the part of the spectrum with
..
  .. math::
..
    (\omega/\omega_0) \;\in\; [14.9, 15.1] \cup [16.9, 17.1] \cup [18.9, 19.1],
..
  where :math:`\omega_0` is the driving field frequency. The ``omega`` return value of the :ref:`dipole_response` module or the :ref:`harmonic_propagation` module will be reduced accordingly.

.. rubric:: Control Disk Space Usage

If you are using the on-disk cache and the cache files get to large, you can also specify that only certain parts of the frequency spectrum should be saved. For this, you set the ``config.omega_ranges`` option on the configuration ``struct()`` of the dipole response module, e.g.::

    config.omega_ranges = [14.9 15.1; 16.9 17.1; 18.9 19.1];

which will only keep the part of the spectrum with

.. math::
    (\omega/\omega_0) \;\in\; [14.9, 15.1] \cup [16.9, 17.1] \cup [18.9, 19.1],

where :math:`\omega_0` is the driving field frequency. The ``omega`` return value of the :ref:`dipole_response` module or the :ref:`harmonic_propagation` module will be reduced accordingly.

.. note::
   You can also apply this option to reduce RAM usage when on-disk cache is desactivated.

.. rubric:: Use Network Storage

If you want to save the whole spectrum, it may be convenient to use high-capacity network storage. For this, simply set the ``config.cache.directory`` option to a network location.

However, it is a good idea to also provide an additional local cache directory for operations that need fast access. This directory will consume significantly less space (only two z slices at a time), it can be specified like this::

  config.cache.fast_directory = 'cache/';

.. note::
   You can also set the ``fast_directory`` option to a SSD and the ``directory`` option to a conventional hard drive to improve performance.

.. rubric:: Exploit Symmetry

Another way to save computation time is applicable if you have a spatially symmetric driving field. In this case, you can tell the :ref:`dipole_response` module of the symmetry using the ``symmetry`` option, e.g.::

  config.symmetry = 'x';

Currently, five values are allowed: ``''`` for no symmetry, ``'x'`` for mirror symmetry with respect to the :math:`x`-:math:`z` plane, ``'y'`` for mirror symmetry with respect to the :math:`y`-:math:`z` plane, and ``'xy'`` for symmetry with respect to both planes. This will reduce the computation time by approximately a factor of 2 or 4, respectively. For rotational symmetry around the optical axis, use the value ``'rotational'``.

.. rubric:: Disable discretization checks

Both the :ref:`harmonic_propagation` module and the :ref:`farfield` module issue warnings if you can expect numerical problems (due to insufficient discretization or zero padding). For this, computationally expensive runtime checks are performed.

If you did already some tests runs and are sure that your settings are okay, you can deactivate these tests by settings the ``nochecks`` option, e.g.

::

  propagation_config.nochecks = 1;

::

  ff_config.nochecks = 1;

Example
-------

We use the example from the :ref:`far_field` chapter, but this time we use pulses instead of a :math:`\cos` driving field. We apply all of the possible optimizations.

In this example, without the ``omega_ranges`` option, each cache file would need approximately 650 MB of RAM. By setting it to ``[10 30]``, it is only 1.3 MB. Here we use :math:`30\;\mathrm{fs}` pulses; if you have e.g. :math:`180\;\mathrm{fs}` pulses, you need six times as much space per slice, i.e. 3.9 GB, without applying the optimization.

By using the rotational symmetry option, the memory requirements are reduced further, and computation time is reduced significantly.

.. literalinclude:: ../../../examples/tutorial/resources/efield.m
   :language: matlab
   :emphasize-lines: 41, 44-45, 48, 71, 74, 98

.. rubric:: Now, you know...

... how to improve computation speed and how to do calculations without running into RAM or disk space problems.
