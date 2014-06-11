.. _resources:

Dealing with RAM and CPU Restrictions
=====================================

.. highlight:: matlab

Depending on the simulation parameters, the computation can be very demanding for standard PC hardware. One issue are the RAM requirements. If you call the :ref:`dipole_response` module directly, for each point of the discretized interaction volume one dipole spectrum must be stored. In general, you can compute the amount of RAM you need with the following formula (in MB)::

  length(xv) * length(yv) * length(zv) * length(t_cmc)/2 * 8*2 / 1000 / 1000

To compute with elliptical polarization, you need twice as much RAM.

If you do not directly call the :ref:`dipole_response` module, but use the :ref:`harmonic_propagation` module, only one :math:`z` slice must be kept in RAM at a time. So you can compute the RAM requirements with this formula (again in MB)::

  length(xv) * length(yv) * length(t_cmc)/2 * 8*2 / 1000 / 1000

.. rubric:: Reduce RAM Usage

If this is too much, you can instruct the program to only keep only a part of the computed spectrum and discard the rest. For this, you set the ``cache_omega_ranges`` option on the configuration ``struct()`` of the dipole reponse module, e.g.

::

  config.cache_omega_ranges = [14.9 15.1; 16.9 17.1; 18.9 19.1];

which will only keep the part of the spectrum with

.. math::

  (\omega/\omega_0) \;\in\; [14.9, 15.1] \cup [16.9, 17.1] \cup [18.9, 19.1],

where :math:`\omega_0` is the driving field frequency. The ``omega`` return value of the :ref:`dipole_response` module or the :ref:`harmonic_propagation` module will be reduced accordingly.

.. rubric:: Use Cache

The previous adjustment will only reduce RAM requirements. Another issue is the computation time. Often, it is necessary to only adapt some parameters e.g. for the :ref:`harmonic_propagation` module or the :ref:`farfield` module, but you do not want to recompute the already computed dipole spectra, as this is very time-consuming. To avoid this, you can use the built-in cache functionality of the :ref:`dipole_response` module, which can be activated by the ``cachedir`` configuration option, e.g.::

  config.cachedir = 'cache';

If you set this field on the configuration ``struct()`` for the :ref:`dipole_response` module, computed dipole spectra will be saved in the specified directory. If you call your program again, it will be checked if the parameters have changed, and if they haven't, the saved spectra will be used.

.. rubric:: Exploit Symmetry

Another way to save computation time is applicable if you have a spatially symmetric driving field. In this case, you can tell the :ref:`dipole_response` module of the symmetry using the ``symmetry`` option, e.g.::

  config.symmetry = 'x';

Currently, four values are allowed: ``''`` for no symmetry, ``'x'`` for mirror symmetry with respect to the :math:`x`-:math:`z` plane, ``'y'`` for mirror symmetry with respect to the :math:`y`-:math:`z` plane, and ``'xy'`` for symmetry with respect to both planes. This will reduce the computation time by approximately a factor of 2 or 4, respectively.

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

In this example, without the ``cache_omega_ranges`` option, you would need approximately 650 MB of RAM. By setting it to ``[20.9, 21.1]``, the RAM requirements are reduced to approximately 1.3 MB (plus temporary variables and overhead). Here we use :math:`30\;\mathrm{fs}` pulses; if you have e.g. :math:`180\;\mathrm{fs}` pulses, you need six times as much RAM, i.e. 3.9 GB, without applying the optimization.

The computation time is around 4 hours on a 2.5 GHz dual core processor.

.. literalinclude:: ../../../examples/tutorial/resources/efield.m
   :language: matlab
   :emphasize-lines: 40, 43, 46, 69, 93

.. rubric:: Now, you know...

... how to improve computation speed and how to do calculations without running into RAM problems.
