@echo off
echo ========== PYPY3 ===========
echo ========= Building =========
:: My default python is 3.9 - change to python3 if needed.
pypy3 setup.py build_ext --inplace

echo ========= Running =========
pypy3 testpy.py

pause