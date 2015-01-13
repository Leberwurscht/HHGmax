.. _sau_convert:

sau_convert
-----------

Description
~~~~~~~~~~~

Most calculations are done in scaled atomic units internally. The
``sau_convert`` module helps you to convert between SI units and
scaled atomic units.

Arguments and Return Values
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The signature of the ``sau_convert`` function is

::

    function converted = hhgmax.sau_convert(value, quantity, target, config)
        

The return value ``converted`` is the converted input value, either in
SI units or in scaled atomic units depending in which direction you ask
the module to convert. The arguments are:

-  ``value`` is the value that should be converted

-  ``quantity`` is the respective physical quantity as a symbol;
   currently supported are ``'E'`` (electric field), ``'U'`` (energy),
   ``'s'`` (length), ``'A'`` (area), ``'V'`` (volume), ``'t'`` (time)
   and ``'v'`` (speed)

-  ``target`` gives the direction of the conversion. If it is ``'SI'``,
   the value is converted from scaled atomic units to SI units; if it is
   ``'SAU'``, conversion is done vice versa

-  ``config`` is a ``struct()`` with at least one field:

  -  ``config.wavelength`` must be set to the central wavelength of the
     driving field, in :math:`\milli\meter`.

.. Example
   ~~~~~~~
