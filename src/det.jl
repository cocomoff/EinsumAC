# -*- coding: utf-8 -*-

using Einsum

eijk = zeros(3, 3, 3)
eijk[1, 2, 3] = eijk[2, 3, 1] = eijk[3, 1, 2] = 1
eijk[1, 3, 2] = eijk[3, 2, 1] = eijk[2, 1, 3] = -1

# A = transpose(reshape(1:9, (3, 3)))
A = randn(3, 3)
det_julia = det(A)
A1 = A[:, 1]
A2 = A[:, 2]
A3 = A[:, 3]
@einsum det_einsum := eijk[i,j,k] * A1[i] * A2[j] * A3[k]
println(det_julia)
println(det_einsum)    
