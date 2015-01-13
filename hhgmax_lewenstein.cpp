/*

This file provides the interface to Mablab.
Alternatively you could use lewenstein.hpp directly from your own C++ code.

Compilation for Ubuntu/Octave:
  # apt-get install liboctave-dev build-essential
  # CPPFLAGS="-fopenmp -O3 -ansi" LDFLAGS="$CPPFLAGS" mkoctfile -lgomp --mex hhgmax_lewenstein.cpp

  notes: * option -ffast-math will improve speed by 10% but might be unsafe
         * for older systems, you may have to replace liboctave-dev by octave-headers

Compilation for Windows/Matlab:
  From within Matlab:
    > mex hhgmax_lewenstein.cpp COMPFLAGS="/openmp $COMPFLAGS"

  For installing the compiler, see the compilation chapter of the tutorial.

Running under Windows/Matlab after compilation:
  vcomp90.dll is needed for openmp. The file is included in the Microsoft Visual C++ Redistributable Package,
  and must be placed in the same directory with the mex file.
  The dll32 and dll64 directories should include a copy of this file.

Arguments:
  t - time axis in scaled atomic units; must be equally spaced and start at 0
  Et - time-dependent electric field in scaled atomic units; may be one-, two-
       or three-dimensional and must have shape dimensions x length(t)
  config - a struct() with the following fields:
    ip - the ionization potential in scaled atomic units
    epsilon_t - specifies the spread of the returning wave packet
    weights - weights for integration; useful for implementing soft windows.
              length of this array determines length of integration interval
    ground_state_amplitude - time-dependent ground state amplitude, allows to
                             account for ground state depletion. length of this
                             array must be the same as t argument
    dipole_method (optional) - one of 'H' (default) or 'symmetric_interpolate'

    If 'H' is chosen:
      alpha (optional) - depth of hydrogen-like potential, in units of ip
    If 'symmetric_interpolate' is chosen:
      deltav - spacing of v axis, which is assumed to be equally spaced and to
               start at zero
      dipole_elements - D(v) axis

Return value:
  dt - time-dependent single-atom dipole response in scaled atomic units

*/

#include "lewenstein.hpp"

using namespace std;
#include <string>

// next 3 lines needed for some versions of VC++, otherwise <complex> can't be included
#ifdef _CHAR16T
  #define __STDC_UTF_16__
#endif

#include <mex.h>

template <int dim>
mxArray *call_lewenstein(int N, double *t, double *Et, const mxArray *config) {
  mxArray *d = mxCreateDoubleMatrix(dim,N,mxREAL);

  int weights_length;
  double ip, epsilon_t, *weights, *at, *output;
  string dipole_method;

  mxArray *field;

  field = mxGetField(config, 0, "ip");
  if (!field || !mxIsDouble(field)) mexErrMsgTxt("config needs an ip field of type double.");
  ip = mxGetScalar(field);

  field = mxGetField(config, 0, "epsilon_t");
  if (!field || !mxIsDouble(field)) {
    epsilon_t = 1.0e-4;
  }
  else {
    epsilon_t = mxGetScalar(field);
  }

  field = mxGetField(config, 0, "ground_state_amplitude");
  if (!field || !mxIsDouble(field)) mexErrMsgTxt("config needs a ground_state_amplitude field of type double.");
  at = mxGetPr(field);
  if (N!=(int)mxGetNumberOfElements(field)) mexErrMsgTxt("ground_state_amplitude should have same number of elements as t axis");

  field = mxGetField(config, 0, "weights");
  if (!field || !mxIsDouble(field)) mexErrMsgTxt("config needs a weights field of type double.");
  weights = mxGetPr(field);
  weights_length = (int)mxGetNumberOfElements(field);

  field = mxGetField(config, 0, "dipole_method");
  if (!field || !mxIsChar(field)) {
  //  mexErrMsgTxt("config needs a dipole_method field of type string.");
    dipole_method = "H";
  }
  else {
    dipole_method = string((char *)mxGetPr(field), (int)mxGetNumberOfElements(field));
  }

  output = mxGetPr(d);

  if (dipole_method=="H") {
    double alpha;

    field = mxGetField(config, 0, "alpha");
    if (!field || !mxIsDouble(field)) {
      alpha = 2 * ip;
    }
    else {
      alpha = mxGetScalar(field) * ip;
    }

    dipole_elements_H<dim,double> dp(alpha);
    lewenstein<dim,double>(N, t, Et, weights_length, weights, at, ip, epsilon_t, dp, output);
  }
  else if (dipole_method=="symmetric_interpolate") {
    field = mxGetField(config, 0, "deltav");
    if (!field || !mxIsDouble(field)) mexErrMsgTxt("config needs a deltav field of type double for this dipole_method.");
    double deltap = mxGetScalar(field);

    field = mxGetField(config, 0, "dipole_elements");
    if (!field || !mxIsDouble(field)) mexErrMsgTxt("config needs a dipole_elements field of type double for this dipole_method.");
    double *dipole_real = mxGetPr(field);
    int dipole_length = mxGetNumberOfElements(field);
    double *dipole_imag = mxGetPi(field);
    if (!dipole_imag)  mexErrMsgTxt("config.dipole_elements must be complex.");

    dipole_elements_symmetric_interpolate<dim,double> dp(dipole_length, deltap, dipole_real, dipole_imag);
    lewenstein<dim,double>(N, t, Et, weights_length, weights, at, ip, epsilon_t, dp, output);
  }
  else {
    mexErrMsgTxt("Unknown dipole_method.");
  }

  return d;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  int N, dim;
  double *t, *Et;
  mxArray *d;

  // check number and types of input/output arguments
  if (nrhs != 3) mexErrMsgTxt("Three input arguments required: t, Et, config.");
  else if (!mxIsDouble(prhs[0])) mexErrMsgTxt("t must be double.");
  else if (!mxIsDouble(prhs[1])) mexErrMsgTxt("Et must be double.");
  else if (!mxIsStruct(prhs[2])) mexErrMsgTxt("config must be struct.");
  else if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments.");
  }

  // get dimensions and check them
  N = (int)mxGetNumberOfElements(prhs[0]);
  t = mxGetPr(prhs[0]);
  Et = mxGetPr(prhs[1]);

  if (mxGetNumberOfDimensions(prhs[1]) != 2) mexErrMsgTxt("Et must be a matrix.");
  const mwSize *EtDim = mxGetDimensions(prhs[1]);
  dim = EtDim[0];
  if (EtDim[1] != N || dim < 1 || dim > 3) mexErrMsgTxt("Et must have shape dimensions x numel(t), with dimensions = 1/2/3.");

  // make sure t(1) is zero
  if (abs(t[0]) > 1e-20) mexErrMsgTxt("t(1) must be zero.");

  // case-by-case for different numbers of dimensions
  if (dim==1) d = call_lewenstein<1>(N, t, Et, prhs[2]);
  else if (dim==2) d = call_lewenstein<2>(N, t, Et, prhs[2]);
  else if (dim==3) d = call_lewenstein<3>(N, t, Et, prhs[2]);

  plhs[0] = d;
}
