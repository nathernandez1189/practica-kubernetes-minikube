import numpy
import numba
from numba import cuda

print('Hello world')
print(numba.__version__)
print(cuda.gpus)
print(cuda.detect())
