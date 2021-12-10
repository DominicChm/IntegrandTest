# A cut down version of Scipy's _stats.pxd file. Isolates studentized range related code for testing.

# destined to be used in a LowLevelCallable

cdef double _studentized_range_cdf(int n, double[2] x, void *user_data) nogil
cdef double _studentized_range_cdf_asymptotic(double z, void *user_data) nogil
cdef double _studentized_range_pdf(int n, double[2] x, void *user_data) nogil
cdef double _studentized_range_moment(int n, double[3] x_arg, void *user_data) nogil
cdef double _phi(double z) nogil
cdef double _logphi(double z) nogil
cdef double _Phi(double z) nogil
