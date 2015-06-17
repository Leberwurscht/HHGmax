Installation
============

For working with the framework, simply extract the archive to a folder. This is a
list of contained files, minus some lower level modules::

    hhgmax_load.m
    hhgmax_dipole_response.m
    hhgmax_plane_wave_driving_field.m
    hhgmax_pulse.m
    hhgmax_gh_driving_field.m
    hhgmax_gh_mode.m
    hhgmax_harmonic_propagation.m
    hhgmax_farfield.m
    hhgmax_information.m
    hhgmax_sau_convert.m

    hhgmax_lewenstein.mexw32
    hhgmax_lewenstein.mexw64

    hhgmax_lewenstein.cpp
    lewenstein.hpp
    vec.hpp

    lewenstein.cpp
    pylewenstein.py

    examples/
    doc/

..
    vcomp90_x86-32.dll
    vcomp90_x86-64.dll
    gated_pulse.m (experimental)
    grating.m (experimental)
    screen.m (experimental)

The framework contains one routine (hhgmax_lewenstein.cpp) written in C++ for better
performance, which must be compiled manually if you use Linux with Octave (see
chapter :ref:`compilation`).
All example files of this tutorial and of the reference manual can be found in the
``examples/`` subfolder.
