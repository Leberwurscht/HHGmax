.. _compilation:

Compilation
===========

MATLAB under Windows
--------------------

If you use MATLAB under Windows, it should be sufficient to copy the program directory to your disk. In order for the C++ implementation of the Lewenstein model to run, you may need the DLL file vcomp90.dll.
For the case that your system does not provide this file, the program directory contains a 32-bit and a 64-bit version of it (``vcomp90_x86-32.dll`` and ``vcomp90_x64-64.dll``) that you can rename to ``vcomp90.dll``.
Alternatively, you can obtain this file from the Microsoft Visual C++ Redistributable Package.

The program comes with precompiled 32-bit and 64-bit executables for the C++
implementation of the Lewenstein model, so usually you don't need to compile anything.
If you make changes to the C++ part of the code, however, you will need to
recompile. This works from within MATLAB, but you will need Microsoft Visual
Studio C++ installed unfortunately, the free Express version of the compiler does
not produce multi-processor capable executables.
To compile the Lewenstein implementation, open MATLAB, change your working directory to the program directory,
and run

.. code-block:: matlab

    > mex lewenstein.cpp COMPFLAGS="/openmp $COMPFLAGS"

With some tweaking, it is also possible to use the Express version of the compiler to
produce multi-processor capable executables. For this, you need to obtain ``vcomp.lib``
from the Windows SDK and copy it to the
``VC\lib\ARCH`` subdirectory of your Visual
Studio installation directory, where
``ARCH``
must be replaced by your architecture.

Also, as an alternative to Microsoft Visual Studio C++, you can use the open
source compiler TDM-GCC_ (see http://stackoverflow.com/questions/8552580/using-gccmingw-as-matlabs-mex-compiler#answer-9453099). At installation, you must select ``Components > gcc > openmp``.

To compile a .mex file for 64-bit MATLAB, open MinGW Command
Prompt, change your working directory to the program directory, and run:

.. code-block:: bat

    > set MATLAB=YOUR_MATLAB_PATH
    > x86_64-w64-mingw32-c++ -m64 -shared -I"%MATLAB%/extern/include" -DMATLAB_MEX_FILE ^
      -fopenmp -O3 -ansi -o lewenstein.mexw64 -Wl,--export-all-symbols lewenstein.cpp ^
      -L"%MATLAB%/bin/win64" -lmex -lmx -leng -lmat

To compile for 32-bit MATLAB, use these commands:

.. code-block:: bat

    > set MATLAB=YOUR_MATLAB_PATH
    > mingw32-c++ -shared -I"%MATLAB%/extern/include" DMATLAB_MEX_FILE ^
      -fopenmp -O3 -ansi -o lewenstein.mexw32 -Wl,--export-all-symbols lewenstein.cpp ^
      -L"%MATLAB%/bin/win32" -lmex -lmx -leng -lmat

.. _TDM-GCC: http://tdm-gcc.tdragon.net/

GNU Octave under Linux
----------------------

If you use Linux and GNU Octave, you need to compile the C++ part of the program
yourself, but this is very easy. For Debian or Ubuntu, you need to make sure that
you have installed the packages ``octave``, ``liboctave-dev`` [#headers-note]_ and ``build-essential``.


The package names for other distributions should be similar. Then you must change
your working directory to the main directory of the code and execute:

.. code-block:: bash

    $ CPPFLAGS="-fopenmp -O3 -ansi" LDFLAGS="$CPPFLAGS" mkoctfile -lgomp --mex lewenstein.cpp

.. [#headers-note] Older systems might need ``octave-headers`` instead of ``liboctave-dev``
