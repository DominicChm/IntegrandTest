import csv
import sys

if len(sys.argv) != 3:
    raise RuntimeError("Unexpected number of inputs")

fCPython = open(sys.argv[1], 'r')
fPyPy = open(sys.argv[2], 'r')

CPythonReader = csv.reader(fCPython)
PyPyReader = csv.reader(fPyPy)

results = zip(CPythonReader, PyPyReader)

print("Comparing element-wise...")
for cres, pres in results:
    if cres != pres:
        print(f"MISMATCH: CPython: {cres}, PyPy: {pres}")
print("Done!")

