# -*- coding: utf-8 -*-

using Einsum

function benchmark(;dim1=30, dim2=20)
    A = randn(dim1, dim2)
    B = randn(dim1, dim2)
    C = randn(dim1, dim2)
    D = randn(dim1, dim2)
    E = randn(dim1, dim2)
    X = zeros(dim2, dim2, dim2, dim2, dim2)
    @einsum X[a,b,c,d,e] = A[r,a] * B[r,b] * C[r,c] * D[r,d] * E[r,d]
end


open("../time_julia.csv", "w") do fp
    for n = 5:39
        tic()
        benchmark(dim2=n)
        write(fp, "$n,$(toq())\n")
    end
end

