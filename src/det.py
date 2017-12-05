# -*- coding: utf-8 -*-

import numpy as np

eijk = np.zeros((3, 3, 3))
eijk[0, 1, 2] = eijk[1, 2, 0] = eijk[2, 0, 1] = 1
eijk[0, 2, 1] = eijk[1, 0, 2] = eijk[2, 1, 0] = -1


A = np.arange(9).reshape(3, 3)
det_numpy = np.linalg.det(A)
det_einsum = np.einsum("ijk,i,j,k", eijk, A[0], A[1], A[2])
print(det_numpy, det_einsum)
