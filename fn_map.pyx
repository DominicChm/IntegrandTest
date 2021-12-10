cimport stats

from cpython.pycapsule cimport PyCapsule_New, PyCapsule_GetPointer

ctypedef double (*util_f)(double)
def phi(double x):
    cdef char * name = '_phi'
    cdef void * f = <void *> stats._phi
    cdef object capsule = PyCapsule_New(f, name, NULL)

    return (<util_f> PyCapsule_GetPointer(capsule, name))(x)

def logphi(double x):
    cdef char * name = '_logphi'
    cdef void * f = <void *> stats._logphi
    cdef object capsule = PyCapsule_New(f, name, NULL)

    return (<util_f> PyCapsule_GetPointer(capsule, name))(x)

ctypedef double (*integrand_f)(int n, double[2] x, void *user_data)

def cdf(double z, double s, double log_const, double q, double k, double df):
    cdef double[4] user_data = [q, k, df, log_const]
    cdef double[2] integration_var = [z, s]

    cdef char * name = '_studentized_range_cdf'
    cdef void * f = <void *> stats._studentized_range_cdf

    cdef object capsule = PyCapsule_New(f, name, NULL)
    return (<integrand_f> PyCapsule_GetPointer(capsule, name))(2, integration_var, <void *> user_data)

def pdf(double z, double s, double log_const, double q, double k, double df):
    cdef double[4] user_data = [q, k, df, log_const]
    cdef double[2] integration_var = [z, s]

    cdef char * name = '_studentized_range_pdf'
    cdef void * f = <void *> stats._studentized_range_pdf

    cdef object capsule = PyCapsule_New(f, name, NULL)
    return (<integrand_f> PyCapsule_GetPointer(capsule, name))(2, integration_var, <void *> user_data)

def moment(double z, double s, double q, double log_const, double K, double k, double df):
    cdef double[4] user_data = [K, k, df, log_const]
    cdef double[3] integration_var = [z, s, q]

    cdef char * name = '_studentized_range_moment'
    cdef void * f = <void *> stats._studentized_range_moment

    cdef object capsule = PyCapsule_New(f, name, NULL)
    return (<integrand_f> PyCapsule_GetPointer(capsule, name))(3, integration_var, <void *> user_data)

#cdef double _studentized_range_cdf_asymptotic(double z, void *user_data) nogil
#cdef double _studentized_range_moment(int n, double[3] x_arg, void *user_data) nogil

#cdef double _Phi(double z) nogil
