Installation
============

For working with the framework, simply extract the archive to a folder. This is the
list of contained files, minus some lower level modules::

    dipole_response.m
    plane_wave_driving_field.m
    pulse.m
    gh_driving_field.m
    gh_mode.m
    harmonic_propagation.m
    farfield.m
    information.m
    sau_convert.m

    lewenstein.mexw32
    lewenstein.mexw64

    lewenstein.cpp
    lewenstein.hpp
    vec.hpp

    examples/
    doc/

..
    vcomp90_x86-32.dll
    vcomp90_x86-64.dll
    gated_pulse.m (experimental)
    grating.m (experimental)
    screen.m (experimental)

The framework contains one routine (lewenstein.cpp) written in C++ for better
performance, which must be compiled manually if you use Linux with Octave (see
chapter :ref:`compilation`).
All example files of this tutorial and of the reference manual can be found in the
``examples/`` subfolder.
