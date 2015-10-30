using namespace std;

#include "vec.hpp"

// lewenstein() needs dipole elements. One solution would be to pass a function
// pointer, but as the calculation needs additional data, this would require
// global variables.
// A better solution is to pass a class instance. This instance can contain the
// needed data, and has a method that returns the dipole element for a given p.
// This defines the interface for such classes.
template <int dim, typename Type>
class dipole_elements {
  public:
    virtual vec<dim,complex<Type> > get(const vec<dim,Type> &p) const = 0;
};

// dipole elements for hydrogen ground state with custom alpha
// d(p) = i * 2^3.5*alpha^1.25/pi * p/(p^2 + alpha)^3
template <int dim, typename Type>
class dipole_elements_H : public dipole_elements<dim,Type> {
  private:
    complex<Type> prefactor;
    Type alpha;

  public:
    dipole_elements_H(Type alph) {
      const Type pi = 4.0*atan(1.0);
      const complex<Type> i(Type(0), Type(1));

      alpha = alph;
      prefactor = pow(2,3.5) * pow(alph,1.25) / pi * i;
    };

    vec<dim,complex<Type> > get(const vec<dim,Type> &p) const {
      vec<dim,complex<Type> > r(p);
      r *= prefactor / pow(SQR(p) + alpha, 3);
      return r;
    };
};

// linear interpolation for antisymmetric dipole elements (symmetric ground state)
template <int dim, typename Type>
class dipole_elements_symmetric_interpolate : public dipole_elements<dim,Type> {
  private:
    int length;
    Type deltap;
    Type *dipole_real;
    Type *dipole_imag;

  public:
    dipole_elements_symmetric_interpolate(int N, Type dp, Type *dr, Type *di) {
      length = N;
      deltap = dp;
      dipole_real = dr;
      dipole_imag = di;
    };

    vec<dim,complex<Type> > get(const vec<dim,Type> &p) const {
      vec<dim,complex<Type> > r;
      Type p_abs;
      int datapoint_before;
      complex<Type> d_before, d_after;

      p_abs = abs(p);
      datapoint_before = (int)(p_abs/deltap);
      if (!p_abs) {
        // special case for p_abs=0, otherwise we get division by zero
        r = complex<Type>(dipole_real[0],dipole_imag[0]);
      }
      else if (datapoint_before<length-1) {
        complex<Type> d_before = complex<Type>(dipole_real[datapoint_before],dipole_imag[datapoint_before]);
        complex<Type> d_after = complex<Type>(dipole_real[datapoint_before+1],dipole_imag[datapoint_before+1]);
        r = p / p_abs; // get direction of d vector from direction of p vector
        r *= (d_after-d_before)*(p_abs/deltap-datapoint_before) + d_before;
          // length of p vector is determined by linear interpolation
      }
      else {
        // p too large - not enough data
        r = 0;
      }

      return r;
    };
};

// calculates dipole response
template <int dim, typename Type>
int lewenstein(const int N, Type *t, Type *Et_data, int weight_length, Type *weights, Type *at, Type Ip, Type epsilon_t, const dipole_elements<dim,Type> &dp, Type *output_data) {
  typedef complex<Type> cType;
  typedef vec<dim,Type> rvec;
  typedef vec<dim,cType> cvec;
  typedef vec_array<dim,Type> rvec_array;

  int t_i, tau_i;
  Type pi = 4.0*atan(1.0);
  cType i = cType(Type(0), Type(1));

  // initialize Et, At, Bt, Ct, output
  rvec_array Et(Et_data);
  Type *At_data = new Type[dim*N]; rvec_array At(At_data);
  Type *Bt_data = new Type[dim*N]; rvec_array Bt(Bt_data);
  Type *Ct = new Type[N];
  rvec_array output(output_data);

  rvec IAt(0);
  rvec IBt(0);
  Type ICt = Type(0);

  At[0] = IAt;
  Bt[0] = IBt;
  Ct[0] = ICt;

  for (t_i=1; t_i<N; t_i++) {
    Type dt = t[t_i]-t[t_i-1];

    IAt -= (Et[t_i-1]+Et[t_i]) * (dt/2);
    At[t_i] = IAt;

    IBt += (At[t_i-1]+At[t_i]) * (dt/2);
    Bt[t_i] = IBt;

    ICt += (SQR(At[t_i-1]) + SQR(At[t_i])) * dt/2;
    Ct[t_i] = ICt;
  }

  cvec integral, last_integrand, dstar, dnorm, integrand13;
  cType c;
  rvec pst, argdstar, argdnorm;
  Type Sst, dt;
  int inde;

  #pragma omp parallel for private(inde, integral, last_integrand, pst, tau_i, argdstar, argdnorm, dstar, dnorm, Sst, c, integrand13, dt) shared(t, Et, At, Bt, Ct, i, pi, weights, weight_length, at, Ip, dp)
  for (t_i=1; t_i<N; t_i++) {
    inde = weight_length;
    if (t_i<inde) inde = t_i+1;

    integral = 0.;
    last_integrand = 0;

    for (tau_i=0; tau_i<inde; tau_i++) {
      pst = (Bt[t_i]-Bt[t_i-tau_i]) / t[tau_i];
      if (tau_i==0) pst = At[t_i];

      argdstar = pst - At[t_i];
      argdnorm = pst - At[t_i-tau_i];

      // calculate dipole elements with passed function
      dnorm = dp.get(argdnorm);
      dstar = conj( dp.get(argdstar) );

      Sst = Ip * t[tau_i] - .5/t[tau_i]*SQR(Bt[t_i]-Bt[t_i-tau_i]) + .5*(Ct[t_i]-Ct[t_i-tau_i]);
      if (tau_i==0) Sst = 0;

      c = pi/(epsilon_t+(Type)0.5*i*t[tau_i]);

      // note: c*sqrt(c) is a lot faster than pow(c, 1.5) - yields 50% speed improvement
      integrand13 = dstar;
      integrand13 *= (dnorm * Et[t_i-tau_i]) * c*sqrt(c) * cType( cos(Sst), -sin(Sst) ) * weights[tau_i] * at[t_i] * at[t_i-tau_i]; // takes most of the time!
        // for the a(t) & a(t-tau) terms, compare Cao et al. (2006) in Phys. Rev. A

      dt=0; if (tau_i>0) dt = t[tau_i]-t[tau_i-1];
      integral += (last_integrand + integrand13) * cType(dt/2.);

      last_integrand = integrand13;
    }

    output[t_i] = (Type)2.0 * imag(integral);
  }

  output[0] = 0;

  delete[] At_data;
  delete[] Bt_data;
  delete[] Ct;

  return 0; // might be replaced by error code later, e.g. for failed interpolation
};

// calculates dipole response in saddle point approximation applied to tau:
//   Yakovlev, Ivanov, and Krausz, "Enhanced Phase-Matching for Generation of Soft X-Ray Harmonics and Attosecond Pulses in Atomic Gases."
template <int dim, typename Type>
int yakovlev(const int N, Type *t, Type *Et_data, int max_tau_i, Type *at, Type *tb_window, Type Ip, int trajectories, int skip, Type *output_data) {
  typedef complex<Type> cType;
  typedef vec<dim,Type> rvec;
  typedef vec<dim,cType> cvec;
  typedef vec_array<dim,Type> rvec_array;

  int t_i, tau_i;
  Type pi = 4.0*atan(1.0);
  cType i = cType(Type(0), Type(1));
  cType isqrtneg = cType(Type(1/sqrt(2)), -Type(1/sqrt(2)));

  // initialize Et, At, Bt, Ct, output
  rvec_array Et(Et_data);
  Type *At_data = new Type[dim*N]; rvec_array At(At_data);
  Type *Bt_data = new Type[dim*N]; rvec_array Bt(Bt_data);
  Type *Ct = new Type[N];
  rvec_array output(output_data);

  rvec IAt(0);
  rvec IBt(0);
  Type ICt = Type(0);

  At[0] = IAt;
  Bt[0] = IBt;
  Ct[0] = ICt;

  for (t_i=1; t_i<N; t_i++) {
    Type dt = t[t_i]-t[t_i-1];

    IAt -= (Et[t_i-1]+Et[t_i]) * (dt/2);
    At[t_i] = IAt;

    IBt += (At[t_i-1]+At[t_i]) * (dt/2);
    Bt[t_i] = IBt;

    ICt += (SQR(At[t_i-1]) + SQR(At[t_i])) * dt/2;
    Ct[t_i] = ICt;
  }

  Type Sst, dt, a_ion;
  cType a_pr;
  int trajectories_found,inde;
  rvec reference_B;
  rvec reference_sign;
  rvec line_at_t, delta_At;
  cvec a_rec;

  #pragma omp parallel for private(tau_i, inde, Sst, dt, reference_B, reference_sign, line_at_t, trajectories_found, a_rec,a_ion,a_pr,delta_At) shared(t, Et, At, Bt, Ct, i, pi, isqrtneg, at, Ip, max_tau_i, trajectories, output)
  for (t_i=1; t_i<N; t_i++) {
    output[t_i] = 0;

    reference_B = Bt[t_i];
    reference_sign = Et[t_i];
    trajectories_found = 0;

    inde = max_tau_i;
    if (t_i<inde) inde = t_i+1;
    for (tau_i=1; tau_i<inde; tau_i++) {
      // check if we found an intersection of the line A(t-tau)*(t-tau)+B(t-tau) with B(t); if not keep searching
      line_at_t = At[t_i-tau_i]*t[tau_i] + Bt[t_i-tau_i];
      if ((line_at_t-reference_B)*reference_sign>0) {
        continue;
      }

      trajectories_found++;

      if (trajectories_found>skip) {
        // compute auxiliary terms
        dt = t[t_i-tau_i+1] - t[t_i-tau_i];
        Sst = Ip * t[tau_i] - .5/t[tau_i]*SQR(Bt[t_i]-Bt[t_i-tau_i]) + .5*(Ct[t_i]-Ct[t_i-tau_i]);
        delta_At = At[t_i-tau_i] - At[t_i];

        // compute probability amplitudes
        a_ion = sqrt( ( SQR(at[t_i-tau_i]) - SQR(at[t_i-tau_i+1]) )/dt );
        a_pr = pow(2*pi,1.5) / t[tau_i] / sqrt(t[tau_i]) * sqrt(sqrt(2*Ip))/abs(Et[t_i-tau_i]) * cType( cos(Sst), -sin(Sst) );
//        a_rec = sqrt(1-SQR(at[t_i])) / pow(2*Ip + SQR(delta_At), 3) * delta_At; // as in reference, but probably wrong
        a_rec = at[t_i] / pow(2*Ip + SQR(delta_At), 3) * delta_At;

        // add to dipole response
        output[t_i] += real(isqrtneg * tb_window[t_i-tau_i] * a_ion * a_pr * a_rec);
      }

      // break if all trajectories found, set new reference sign
      if (trajectories_found==trajectories) break;

      reference_sign = line_at_t-reference_B;
    }
  }

  output[0] = 0;

  delete[] At_data;
  delete[] Bt_data;
  delete[] Ct;

  return 0; // might be replaced by error code later, e.g. for failed interpolation
};
