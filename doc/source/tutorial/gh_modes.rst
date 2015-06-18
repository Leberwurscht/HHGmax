Higher-order Spatial Modes as Driving Field
===========================================

.. highlight:: matlab

For playing with different modes that can be excited in resonators, it is also possible to specify arbitrary superpositions of Gauss-Hermite modes :math:`\mathrm{GH}_{nm}` as driving field.
For example, if you want to use the mode

.. math::

   \sqrt{3/10}\;\mathrm{GH}_{00} - i\sqrt{5/10}\;\mathrm{GH}_{20} + \sqrt{2/10}\;\mathrm{GH}_{03}

which corresponds to the following table of coefficients

==  ==  =====================
n   m   coefficient
==  ==  =====================
0   0   :math:`\sqrt{3/10}`
2   0   :math:`-i\sqrt{5/10}`
0   3   :math:`\sqrt{2/10}`
==  ==  =====================

you replace the line

::

   config.mode = 'TEM00';

by

.. literalinclude:: ../../../examples/tutorial/gh_modes/dipole_spectrum.m
   :language: matlab
   :lines: 20-22

To learn how to get access to the spatially dependent field amplitude of the driving field and plot it, consider the reference of the :ref:`gh_mode` module.

.. rubric:: Now, you know...

... how to specify arbitrary superpositions of Gauss-Hermite modes as driving field.
