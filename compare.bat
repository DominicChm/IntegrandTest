@echo off

echo ====== COMPARE BOTH =======
echo This will take a while because results are written to file.
echo ========= PYTHON3 =========
:: My default python is 3.9 - change to python3 if needed.
python setup.py build_ext --inplace >NUL  2>NUL
python testpy.py w
echo.
echo ========= PYPY3 =========
pypy3 setup.py build_ext --inplace >NUL  2>NUL
pypy3 testpy.py w

echo.
echo ========= COMPARE =========
python compare_results.py RES_CPython-3.9.2.csv RES_PyPy-3.8.12.csv


pause