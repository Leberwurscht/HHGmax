// This file provides a fast implementation of common vector operations, using
// a templated and very lightweight vec class. The memory structure of a vec
// instance is just a sequence of its components.
// It also provides a vec_array class, whose memory structure is just the same
// as a sequence of N*dimensions scalars. The [] operator is overloaded
// to return vec instances.
// The goal of these classes is to achieve similar performance as a primitive
// array for the 1d case, while being able to write more general programs.

// include guard
#ifndef VEC_HPP
#define VEC_HPP

// need complex type for optimized template
#include <complex>

/* -- vec class -- */
template <int dim, typename Type>
class vec { public:
  Type x[dim];

  inline vec() {};

  // copy constructor
  template <typename otherType>
  inline vec(const vec<dim,otherType> &other_vec) {

    for (int i=0; i<dim; i++) {
      x[i] = Type(other_vec.x[i]);
    }
  };

  // intitialize with constant value
  template <typename otherType>
  inline vec(otherType val) {
    for (int i=0; i<dim; i++) {
      x[i] = Type(val);
    }
  };

  // in-place summation
  template <typename otherType>
  inline vec<dim,Type> &operator+=(const vec<dim,otherType> &v) {
    for (int i=0; i<dim; i++) {
      x[i] += Type(v.x[i]);
    }

    return *this;
  };

  // in-place subtraction
  template <typename otherType>
  inline vec<dim,Type> &operator-=(const vec<dim,otherType> &v) {
    for (int i=0; i<dim; i++) {
      x[i] -= Type(v.x[i]);
    }

    return *this;
  };

  // in-place multiplication with scalar
  template <typename otherType>
  inline vec<dim,Type> &operator*=(const otherType &v) {
    for (int i=0; i<dim; i++) {
      x[i] *= Type(v);
    }

    return *this;
  };

  // in-place division by scalar
  template <typename otherType>
  inline vec<dim,Type> &operator/=(const otherType &v) {
    for (int i=0; i<dim; i++) {
      x[i] /= Type(v);
    }

    return *this;
  };

  // element-wise application of a function
  template <typename otherType>
  inline vec<dim,otherType> element_wise(otherType& (*func)(Type&)) {
    vec<dim,otherType> r;
    for (int i=0; i<dim; i++) {
      r.x[i] = (*func)(x[i]);
    }
    return r;
  };
};

/* -- common operations on vec -- */

// sum of vec instances
template <int dim, typename Type>
inline vec<dim,Type> operator+(const vec<dim,Type> &v, const vec<dim,Type> &w) {
  vec<dim,Type> r;

  for (int i=0; i<dim; i++) {
    r.x[i] = v.x[i] + w.x[i];
  }

  return r;
};

// difference of vec instances
template <int dim, typename Type>
inline vec<dim,Type> operator-(const vec<dim,Type> &v, const vec<dim,Type> &w) {
  vec<dim,Type> r;

  for (int i=0; i<dim; i++) {
    r.x[i] = v.x[i] - w.x[i];
  }

  return r;
};

// vec times scalar
template <int dim, typename Type>
inline vec<dim,Type> operator*(const vec<dim,Type> &v, const Type &w) {
  vec<dim,Type> r;

  for (int i=0; i<dim; i++) {
    r.x[i] = v.x[i] * w;
  }

  return r;
};

// scalar times vec
template <int dim, typename Type>
inline vec<dim,Type> operator*(const Type &w, const vec<dim,Type> &v) {
  return v*w;
};

// division of vec by scalar
template <int dim, typename Type>
inline vec<dim,Type> operator/(const vec<dim,Type> &v, const Type &w) {
  vec<dim,Type> r;

  for (int i=0; i<dim; i++) {
    r.x[i] = v.x[i] / w;
  }

  return r;
};

// scalar product of vec instances
template <int dim, typename Type>
inline Type operator*(const vec<dim,Type> &v, const vec<dim,Type> &w) {
  Type r(0);

  for (int i=0; i<dim; i++) {
    r += v.x[i] * w.x[i];
  }

  return r;
};

// these more specialized templates gain some speed for scalar product of complex vec and real vec
template <int dim, typename Type>
inline std::complex<Type> operator*(const vec<dim,std::complex<Type> > &v, const vec<dim,Type> &w) {
  std::complex<Type> r(0);

  for (int i=0; i<dim; i++) {
    r += std::complex<Type>(v.x[i] * w.x[i]);
  }

  return r;
};
template <int dim, typename Type>
inline std::complex<Type> operator*(const vec<dim,Type> &w, const vec<dim,std::complex<Type> > &v) {
  return v*w;
};

// implement real part of a vec
template <int dim, typename Type>
vec<dim,Type> real(const vec<dim,std::complex<Type> > &v) {
  vec<dim,Type> r;

  for (int i=0; i<dim; i++) {
    r.x[i] = real(v.x[i]);
  }

  return r;
};

// implement imaginary part of a vec
template <int dim, typename Type>
vec<dim,Type> imag(const vec<dim,std::complex<Type> > &v) {
  vec<dim,Type> r;

  for (int i=0; i<dim; i++) {
    r.x[i] = imag(v.x[i]);
  }

  return r;
};

// implement complex conjugation of a vec
template <int dim, typename Type>
vec<dim,std::complex<Type> > conj(const vec<dim,std::complex<Type> > &v) {
  vec<dim,std::complex<Type> > r;

  for (int i=0; i<dim; i++) {
    r.x[i] = conj(v.x[i]);
  }

  return r;
};

// implement absolute value of a vec
template <int dim, typename Type>
Type abs(const vec<dim,Type> &v) {
  Type r(0), a;

  for (int i=0; i<dim; i++) {
    a = abs(v.x[i]);
    r += a*a;
  }

  return sqrt(r);
};

/* -- implementation of vec_array -- */
template <int dim, typename Type>
class vec_array { public:
  Type *x;

  inline vec_array() {};

  inline vec_array(Type *a) {
    x = a;
  };

  inline vec<dim,Type> &operator[](int i) {
    return *(vec<dim,Type> *)(&x[dim*i]);
  }
};

/* -- macro to compute the square of vec instances -- */
#define SQR(x) ((x)*(x))

#endif // end of include guard
