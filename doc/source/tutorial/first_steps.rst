First Steps
===========

For using the framework, you write an ``.m`` file in which you set the necessary configuration variables and then call routines of the framework. The routines must be loaded with the ``hhgmax_load`` function. In order that Matlab/Octave can find the ``hhgmax_load`` function, you must either place your own ``.m`` files in
the framework's main directory, or better add the framework directory to the Matlab/Octave search
path, e.g. by using the ``addpath``. Then you are ready to set configuration options and call routines of the framework:

.. literalinclude:: ../../../examples/tutorial/first_steps/show_info.m
   :language: matlab

If executed, this file will output::

    photon_energy_eV = 1.2398
    ip_SAU = 9.7835
    up_SAU = 7.5310
    cutoff_SAU = 33.657
    keldysh_parameter = 0.80594
