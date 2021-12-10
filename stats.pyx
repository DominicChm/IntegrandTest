from libc cimport math

cdef double _phi(double z) nogil:
    """evaluates the normal PDF. Used in `studentized_range`"""
    cdef double inv_sqrt_2pi = 0.3989422804014327
    return inv_sqrt_2pi * math.exp(-0.5 * z * z)

cdef double _logphi(double z) nogil:
    """evaluates the log of the normal PDF. Used in `studentized_range`"""
    cdef double log_inv_sqrt_2pi = -0.9189385332046727
    return log_inv_sqrt_2pi - 0.5 * z * z

cdef double _Phi(double z) nogil:
    """evaluates the normal CDF. Used in `studentized_range`"""
    # use a custom function because using cs.ndtr results in incorrect PDF at
    # q=0 on 32bit systems. Use a hardcoded 1/sqrt(2) constant rather than
    # math constants because they're not available on all systems.
    cdef double inv_sqrt_2 = 0.7071067811865475
    return 0.5 * math.erfc(-z * inv_sqrt_2)

cpdef double _studentized_range_cdf_logconst(double k, double df):
    """Evaluates log of constant terms in the cdf integrand"""
    cdef double log_2 = 0.6931471805599453
    return (math.log(k) + (df / 2) * math.log(df)
            - (math.lgamma(df / 2) + (df / 2 - 1) * log_2))

cpdef double _studentized_range_pdf_logconst(double k, double df):
    """Evaluates log of constant terms in the pdf integrand"""
    cdef double log_2 = 0.6931471805599453
    return (math.log(k) + math.log(k - 1) + (df / 2) * math.log(df)
            - (math.lgamma(df / 2) + (df / 2 - 1) * log_2))

cdef double _studentized_range_cdf(int n, double[2] integration_var,
                                   void *user_data) nogil:
    # evaluates the integrand of Equation (3) by Batista, et al [2]
    # destined to be used in a LowLevelCallable
    q = (<double *> user_data)[0]
    k = (<double *> user_data)[1]
    df = (<double *> user_data)[2]
    log_cdf_const = (<double *> user_data)[3]

    s = integration_var[1]
    z = integration_var[0]

    # suitable terms are evaluated within logarithms to avoid under/overflows
    log_terms = (log_cdf_const
                 + (df - 1) * math.log(s)
                 - (df * s * s / 2)
                 + _logphi(z))

    # multiply remaining term outside of log because it can be 0
    return math.exp(log_terms) * math.pow(_Phi(z + q * s) - _Phi(z), k - 1)

cdef double _studentized_range_cdf_asymptotic(double z, void *user_data) nogil:
    # evaluates the integrand of equation (2) by Lund, Lund, page 205. [4]
    # destined to be used in a LowLevelCallable
    q = (<double *> user_data)[0]
    k = (<double *> user_data)[1]

    return k * _phi(z) * math.pow(_Phi(z + q) - _Phi(z), k - 1)

cdef double _studentized_range_pdf(int n, double[2] integration_var,
                                   void *user_data) nogil:
    # evaluates the integrand of equation (4) by Batista, et al [2]
    # destined to be used in a LowLevelCallable
    q = (<double *> user_data)[0]
    k = (<double *> user_data)[1]
    df = (<double *> user_data)[2]
    log_pdf_const = (<double *> user_data)[3]

    z = integration_var[0]
    s = integration_var[1]

    # suitable terms are evaluated within logarithms to avoid under/overflows
    log_terms = (log_pdf_const
                 + df * math.log(s)
                 - df * s * s / 2
                 + _logphi(z)
                 + _logphi(s * q + z))

    # multiply remaining term outside of log because it can be 0
    return math.exp(log_terms) * math.pow(_Phi(s * q + z) - _Phi(z), k - 2)

cdef double _studentized_range_moment(int n, double[3] integration_var,
                                      void *user_data) nogil:
    # destined to be used in a LowLevelCallable
    K = (<double *> user_data)[0]  # the Kth moment to calc.
    k = (<double *> user_data)[1]
    df = (<double *> user_data)[2]
    log_pdf_const = (<double *> user_data)[3]

    # Pull outermost integration variable out to pass as q to PDF
    q = integration_var[2]

    cdef double pdf_data[4]
    pdf_data[0] = q
    pdf_data[1] = k
    pdf_data[2] = df
    pdf_data[3] = log_pdf_const

    return math.pow(q, K) * _studentized_range_pdf(4, integration_var, <void *> pdf_data)

cpdef double test():
    return 5.0
