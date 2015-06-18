/*

Provides a DLL / shared object file making available the Lewenstein model implemented in lewenstein.hpp.
Only used for the Python module (lewenstein.py); the Matlab/Octave wrapper is implemented in hhgmax_lewenstein.cpp.

Compilation for Linux (compiler is needed; e.g. on Ubuntu: `sudo aptitude install build-essential`):
  # g++ -shared -o lewenstein.so lewenstein.cpp -fPIC -fopenmp -O3 -ansi

  Notes:
    * option -ffast-math will improve speed by 10% but might be unsafe

Compilation for Windows with MinGW, 64 bit (either on Windows or cross-compile on Linux):
  x86_64-w64-mingw32-c++ -m64 -shared -o dll64/lewenstein.dll lewenstein.cpp -fopenmp -O3 -ansi
For 32 bit:
  mingw32-c++ -shared -o dll32/lewenstein.dll lewenstein.cpp -fopenmp -O3 -ansi
  (compiler might be called i686-w64-mingw32-c++ instead of mingw32-c++)

*/


#include "lewenstein.hpp"

extern "C" {
  // expose H dipole elements (constructor and destructor)
  void *dipole_elements_H_double(int dims, double alpha) {
    if (dims==1) {
      dipole_elements_H<1,double> *elements = new dipole_elements_H<1,double>(alpha);
      return elements;
    }
    else if (dims==2) {
      dipole_elements_H<2,double> *elements = new dipole_elements_H<2,double>(alpha);
      return elements;
    }
    else if (dims==3) {
      dipole_elements_H<3,double> *elements = new dipole_elements_H<3,double>(alpha);
      return elements;
    }
    else {
       return 0;
    }
  }

  void dipole_elements_H_double_destroy(int dims, void *ptr) {
    if (dims==1) {
      dipole_elements_H<1,double> *elements = (dipole_elements_H<1,double> *)ptr;
      delete elements;
    }
    else if (dims==2) {
      dipole_elements_H<2,double> *elements = (dipole_elements_H<2,double> *)ptr;
      delete elements;
    }
    else if (dims==3) {
      dipole_elements_H<3,double> *elements = (dipole_elements_H<3,double> *)ptr;
      delete elements;
    }
  }

  // expose symmetric interpolated dipole elements (constructor and destructor)
  void *dipole_elements_symmetric_interpolate_double(int dims, int N, double dp, double *dr, double *di) {
    if (dims==1) {
      dipole_elements_symmetric_interpolate<1,double> *elements = new dipole_elements_symmetric_interpolate<1,double>(N,dp,dr,di);
      return elements;
    }
    else if (dims==2) {
      dipole_elements_symmetric_interpolate<2,double> *elements = new dipole_elements_symmetric_interpolate<2,double>(N,dp,dr,di);
      return elements;
    }
    else if (dims==3) {
      dipole_elements_symmetric_interpolate<3,double> *elements = new dipole_elements_symmetric_interpolate<3,double>(N,dp,dr,di);
      return elements;
    }
    else {
       return 0;
    }
  }
  void dipole_elements_symmetric_interpolate_double_destroy(int dims, void *ptr) {
    if (dims==1) {
      dipole_elements_symmetric_interpolate<1,double> *elements = (dipole_elements_symmetric_interpolate<1,double> *)ptr;
      delete elements;
    }
    else if (dims==2) {
      dipole_elements_symmetric_interpolate<2,double> *elements = (dipole_elements_symmetric_interpolate<2,double> *)ptr;
      delete elements;
    }
    else if (dims==3) {
      dipole_elements_symmetric_interpolate<3,double> *elements = (dipole_elements_symmetric_interpolate<3,double> *)ptr;
      delete elements;
    }
  }

  // expose implementation of Lewenstein model
  void lewenstein_double(int dims, int N, double *t, double *Et, int weights_length, double *weights, double *at, double ip, double epsilon_t, void *dp, double *output) {
    if (dims==1) {
      lewenstein<1,double>(N, t, Et, weights_length, weights, at, ip, epsilon_t, *(dipole_elements_H<1,double> *)dp, output);
    }
    else if (dims==2) {
      lewenstein<2,double>(N, t, Et, weights_length, weights, at, ip, epsilon_t, *(dipole_elements_H<2,double> *)dp, output);
    }
    else if (dims==3) {
      lewenstein<3,double>(N, t, Et, weights_length, weights, at, ip, epsilon_t, *(dipole_elements_H<3,double> *)dp, output);
    }
  }

}
