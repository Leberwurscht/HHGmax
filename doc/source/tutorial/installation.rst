Installation
============

For working with the framework, simply extract the archive to a folder. This is the
list of contained files::

    dipole_response.m
    plane_wave_driving_field.m
    pulse.m
    gh_driving_field.m
    gh_mode.m
    harmonic_propagation.m
    farfield.m
    information.m
    hermite.m
    gated_pulse.m (experimental)
    grating.m (experimental)
    screen.m (experimental)

    lewenstein.cpp
    lewenstein.hpp
    vec.hpp

    lewenstein.mexw32
    lewenstein.mexw64
    vcomp90_x86-32.dll
    vcomp90_x86-64.dll

    examples/

The framework contains one routine (lewenstein.cpp) written in C++ for better
performance, which must be compiled manually if you use Linux with Octave (see
chapter :ref:`compilation`).
All example files of this tutorial and of the reference manual can be found in the
``examples/`` subfolder.
