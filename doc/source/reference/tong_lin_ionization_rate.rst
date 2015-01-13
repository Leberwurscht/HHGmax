.. _tong_lin_ionization_rate:

tong_lin_ionization_rate
------------------------

Description
~~~~~~~~~~~

Calculates the static field ionization rate using the empirical formula
proposed by Tong, Lin (2005), which is the ADK formula with a correction
for higher field strengths.

Arguments and Return Values
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The signature of the ``tong_lin_ionization_rate`` function is

::

    function rate_SI = hhgmax.tong_lin_ionization_rate(E_SI, config)
        
The return value ``rate_SI`` are the ionization rate in SI units, i.e. :math:`\second^{-1}`, corresponding
to the static electric field strengths provided as ``E_SI`` argument.

The arguments are:


-  ``E_SI`` is the field strength of the static electric field in SI units, i.e.  :math:`\volt/\meter`; can be an array

-  ``config`` is a ``struct()`` of following fields:

  -  ``config.atom`` is the element to get the ionization rate for; currently supported is ``'Xe'``, ``'Ar'``, ``'Ne'``, or ``'He'``
  -  ``config.m`` (optional) is the magnetic quantum number, default is :math:`0`
  -  ``config.Z`` (optional) is the charge seen by the electron in :math:`\text{e}`, default is :math:`1`
  -  ``config.C``, ``config.l`` and ``config.ionization_potential`` (optional) can be provided instead of
     ``config.atom`` to specify the necessary parameters :math:`C_l`, :math:`l`, and :math:`I_p`, respectively
  -  ``config.alpha`` (optional) is the constant alpha used in the Tong, Lin (2005) correction; if not provided, it is derived from config.atom argument or if not present, set to zero, i.e. the correction is not applied.


.. Example
   ~~~~~~~
