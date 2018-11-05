
# wMathSpace [![Build Status](https://travis-ci.org/Wandalen/wMathSpace.svg?branch=master)](https://travis-ci.org/Wandalen/wMathSpace)

Collection of functions for matrix math. MathSpace introduces class Space which is a multidimensional structure which in the most trivial case is Matrix of scalars. A matrix of specific form could also be classified as a vector. MathSpace heavily relly on MathVector, which introduces VectorImage. VectorImage is a reference, it does not contain data but only refer on actual ( aka Long ) container of lined data.  Use MathSpace for arithmetic operations with matrices, to triangulate, permutate or transform matrix, to get a specific or the general solution of a system of linear equations, to get LU, QR decomposition, for SVD or PCA. Also, Space is a convenient and efficient data container, you may use it to continuously store huge an array of arrays or for matrix computation.

### Try out
```
npm install
node sample/Sample.s
```




























