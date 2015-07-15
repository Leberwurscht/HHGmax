.. _compilation:

Compilation
===========

MATLAB under Windows
--------------------

If you use MATLAB under Windows, it should be sufficient to copy the program directory to your disk. The program comes with precompiled 32-bit and 64-bit executables for the C++
implementation of the Lewenstein model, so usually you don't need to compile anything.

The C++ implementation of the Lewenstein model may need some additional DLL files to run, they come in the ``dll32`` and ``dll64`` directories and are copied automatically to the main program folder when the :ref:`dipole_response` module is called.

If you make changes to the C++ part of the code, you will need to recompile.
This works from within MATLAB, but you need either the Microsoft Windows SDK installed which is free of charge, or Microsoft Visual C++ Professional.
To compile the Lewenstein implementation, open MATLAB, change your working directory to the program directory,
and run

.. code-block:: matlab

    > mex -setup
    > mex hhgmax_lewenstein.cpp COMPFLAGS="/openmp $COMPFLAGS"

Also, as an alternative to the Microsoft compilers, you can use the open
source compiler TDM-GCC_ (see http://stackoverflow.com/questions/8552580/using-gccmingw-as-matlabs-mex-compiler#answer-9453099).
At installation, you *have* to select ``Components > gcc > openmp`` which is needed for multi-processor support.

To compile a ``.mex`` file for 64-bit MATLAB with it, open MinGW Command
Prompt, change your working directory to the program directory, and run:

.. code-block:: bat

    > set MATLAB=YOUR_MATLAB_PATH
    > x86_64-w64-mingw32-c++ -m64 -shared -I"%MATLAB%/extern/include" -DMATLAB_MEX_FILE ^
      -fopenmp -O3 -ansi -o hhgmax_lewenstein.mexw64 -Wl,--export-all-symbols hhgmax_lewenstein.cpp ^
      -L"%MATLAB%/bin/win64" -lmex -lmx -leng -lmat

To compile for 32-bit MATLAB, use these commands:

.. code-block:: bat

    > set MATLAB=YOUR_MATLAB_PATH
    > mingw32-c++ -shared -I"%MATLAB%/extern/include" -DMATLAB_MEX_FILE ^
      -fopenmp -O3 -ansi -o hhgmax_lewenstein.mexw32 -Wl,--export-all-symbols hhgmax_lewenstein.cpp ^
      -L"%MATLAB%/bin/win32" -lmex -lmx -leng -lmat

In some cases, the 32-bit compiler is called ``i686-w64-mingw32-c++`` instead of ``mingw32-c++``.

.. note::
   You can also use the MinGW cross compiler to compile Windows binaries from Linux, for this use the same commands.

.. _TDM-GCC: http://tdm-gcc.tdragon.net/

MATLAB R2011 or older under Windows
-----------------------------------

Matlab versions before R2012 do not have support for the free compiler from the Microsoft Windows SDK.
If you do not have Microsoft Visual C++ Professional or TDM-GCC_, you can use the free Express edition of
Microsoft Visual C++, but then you need to get an additional file needed for multi-processor support.

For this, install also the Microsoft Windows SDK and copy the file ``vcomp.lib`` which comes with it to
the ``VC\lib\ARCH`` subdirectory of your Visual Studio installation directory, where ``ARCH``
must be replaced by your architecture.

GNU Octave under Linux
----------------------

If you use Linux and GNU Octave, you need to compile the C++ part of the program
yourself, but this is very easy. For Debian or Ubuntu, you need to make sure that
you have installed the packages ``octave``, ``liboctave-dev`` [#headers-note]_ and ``build-essential``.


The package names for other distributions should be similar. Then you must change
your working directory to the main directory of the code and execute:

.. code-block:: bash

    $ CPPFLAGS="-fopenmp -O3 -ansi" LDFLAGS="$CPPFLAGS" mkoctfile -lgomp --mex hhgmax_lewenstein.cpp

.. [#headers-note] Older systems might need ``octave-headers`` instead of ``liboctave-dev``


.. _compilation_python:

Compilation of the Python module
--------------------------------

HHGmax comes with an optional :ref:`Python module <python>` which depends on a DLL (Windows) or shared object (Linux) file. Precompiled DLLs
are provided; if you use Linux you have to compile the shared object file yourself.

For this, make sure you have a compiler (on Debian/Ubuntu install the ``build-essential`` package), then change your working
directory to the main directory of the code and execute:

.. code-block:: bash

  $ g++ -shared -o lewenstein.so lewenstein.cpp -fPIC -fopenmp -O3 -ansi

If you make changes to the C++ code and need to recompile the DLL files on Windows, you can use the TDM-GCC_ compiler.
At installation, you *have* to select ``Components > gcc > openmp`` which is needed for multi-processor support. Alternatively, you can cross-compile from Linux using MingGW (on Debian/Ubuntu install the ``mingw-w64`` package).

To compile the 64-bit DLL file, open MinGW Command Prompt (Windows) or the terminal (Linux cross-compile), change your working directory to the program directory, and run:

.. code-block:: bat

  x86_64-w64-mingw32-c++ -m64 -shared -o dll64/lewenstein.dll lewenstein.cpp -fopenmp -O3 -ansi

For the 32-bit DLL file, use

.. code-block:: bat

  mingw32-c++ -shared -o dll32/lewenstein.dll lewenstein.cpp -fopenmp -O3 -ansi

In some cases, the 32-bit compiler is called ``i686-w64-mingw32-c++`` instead of ``mingw32-c++``.
