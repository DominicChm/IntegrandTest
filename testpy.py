import platform
import csv
import sys

import scipy.integrate
import scipy.stats
from scipy.stats import studentized_range

import numpy as np
import fn_map
import stats

write_limit = 10000
write = len(sys.argv) >= 2 and sys.argv[1] == "w"


def open_csv(prefix):
    f = open(f"./{prefix}_{platform.python_implementation()}-{platform.python_version()}.csv", 'w', newline="")
    cs = csv.writer(f)
    return (cs, f)


def eval_cdf(s, z, q, k, v):
    c = stats._studentized_range_cdf_logconst(k, v)
    return fn_map.cdf(s, z, c, q, k, v)


def eval_pdf(s, z, q, k, v):
    c = stats._studentized_range_pdf_logconst(k, v)
    return fn_map.pdf(s, z, c, q, k, v)


def eval_moment(z, s, q, K, k, v):
    c = stats._studentized_range_pdf_logconst(k, v)
    return fn_map.moment(z, s, q, c, K, k, v)


@np.vectorize
def cdf(q, k, v):
    c = stats._studentized_range_cdf_logconst(k, v)

    def inner(z, s):
        res = fn_map.cdf(z, s, c, q, k, v)
        # print(z, s, c, q, k, v)
        return res

    return scipy.integrate.nquad(inner, ranges=[(-np.inf, np.inf), (0, np.inf)], opts=dict(epsabs=1e-11, epsrel=1e-12))[0]


@np.vectorize
def pdf(q, k, v):
    c = stats._studentized_range_pdf_logconst(k, v)

    def inner(z, s):
        res = fn_map.pdf(z, s, c, q, k, v)

        return res

    res = scipy.integrate.nquad(inner, ranges=[(-np.inf, np.inf), (0, np.inf)], opts=dict(epsabs=1e-11, epsrel=1e-12))[0]
    return res


@np.vectorize
def moment(K, k, v):
    c = stats._studentized_range_pdf_logconst(k, v)

    def inner(z, s, q):
        return fn_map.moment(z, s, q, c, K, k, v)

    res = scipy.integrate.nquad(inner, ranges=[(-np.inf, np.inf), (0, np.inf), (0, np.inf)], opts=dict(epsabs=1e-11, epsrel=1e-12))[0]
    return res


# print(eval_cdf(1, 1, 3, 10, 10))
# print(eval_pdf(1, 1, 3, 10, 10))
# print(eval_moment(1, 1, 3, 1, 10, 10))

# print(cdf(3, 10, 10))
# print(scipy.stats.distributions.studentized_range.cdf(3, 10, 10))
#

scipy_mom_res = scipy.stats.distributions.studentized_range.moment(1, 3, 10)
custom_mom_res = moment(1, 3, 10)

print(f"Moment (SCIPY):  {scipy_mom_res}")
print(f"Moment (CUSTOM): {custom_mom_res}")

scipy_pdf_res = scipy.stats.distributions.studentized_range.pdf(1, 3, 10)
custom_pdf_res = pdf(1, 3, 10)
print(f"PDF (SCIPY):  {scipy_pdf_res}")
print(f"PDF (CUSTOM): {custom_pdf_res}")

print(f"PDF eval 1: {eval_pdf(3, 3, 1, 3, 10)}")
print(f"PDF eval 2: {eval_pdf(1, 1, 1, 3, 10)}")

x = np.linspace(0, 5, 50)


step = 0.1
if write:
    zs = np.mgrid[-100:100:step, 0:100:step].reshape(2, -1).T

    cs, f = open_csv("RES")

    for z, s in zs:
        cs.writerow([f"{eval_pdf(z, s, 3, 3, 10):.16f}"])

    f.close()
