@echo off
echo ========= PYTHON3 ==========
echo ========= Building =========
:: My default python is 3.9 - change to python3 if needed.
python setup.py build_ext --inplace

echo ========= Running =========
python testpy.py

pause