# Einsum.jlの紹介

Einsum.jlはアインシュタインの縮約表記に則った計算をサポートするマクロを提供してくれるパッケージです。物理学や線形代数における行列・ベクトル演算を簡潔に書くことが出来ます。例えば三次元ベクトル$$A=(A_1, A_2, A_3)$$と$$B=(B_1, B_2, B_3)$$について、その内積は

$$
A\cdot B = A_1 B_1 + A_2 B_2 + A_3 B_3
$$

で書けますが、この「要素$$i$$について演算して足す」に相当する部分をEinsum.jlが担います。例えば次のような記事を読んで頂ければ、どういうものなのかもう少し真面目に具体的に分かると思います。

- <a href='http://zellij.hatenablog.com/entry/20130701/p1' target='_blank'>アインシュタインの縮約表記 - 大人になってからの再学習</a>
- <a href='http://www.geocities.jp/hp_yamakatsu/summation.html' target='_blank'>アインシュタインの総和規約／縮約記法をマスターしよう</a>

上の内積の例をjuliaとEinsum.jlを利用して書くと、次のようになります。

```julia
using Einsum.jl
A = randn(3);
B = randn(3);
AB = 0;
@einsum AB = A[i] * B[i] 
println(AB)         # Einsum.jlによる計算
println(dot(A, B))  # build-in functionによる計算
```

変数ABを宣言している場所は、マクロで**=**の代わりに**:=**を利用しても大丈夫です。

```julia
@einsum AB := A[i] * B[i]
```

Juliaの場合、行列の端っこ(bounds)を真面目に考えるか考えないかで計算時間が微妙に短縮されます。Einsum.jlの計算でもこのオプションは実装されていて、**@einsum**の代わりに**@einsimd**マクロを利用します。@einsumはベクトルだけではなく行列、テンソル(3次元以上の多次元配列)についても利用可能。例えばサイズが(5, 3)の行列と(3, 10)の行列の積は(5, 10)の行列になります。

```julia
A = randn(5, 3);
B = randn(3, 10);
@einsum AB[i, k] := A[i, j] * B[j, k]
println(AB)     # Einsum.jlによる計算
println(A * B)  # 行列積による計算
```

JuliaのBounds checkingについて興味があれば、このあたりをご確認ください。
- <a href='http://blog.mwsoft.jp/article/109300824.html' target='_blank'>Juliaの@inboundsを使ってみる : mwSoft blog</a>
- <a href='https://docs.julialang.org/en/latest/devdocs/boundscheck/' target='_blank'>Bounds checking · The Julia Language</a>

