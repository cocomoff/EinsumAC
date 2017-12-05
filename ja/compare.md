# numpyとの比較

Juliaを利用する一つの同期として、Pythonでfor文書くと遅い！というのがあると思います。Python/Numpyのnp.einsumを利用した丁寧な解説記事があったので、それをベースにPythonとJuliaのEinsum（と、その他のパフォーマンス）について比較します。

- <a href='http://www.procrasist.com/entry/einsum' target='_blank'>【einsum】アインシュタインの縮約記法のように使えるnumpyの関数。性能と使い方を解説。 - プロクラシスト</a>
- 比較に関したレポジトリ（ファイル置き場とも）: https://github.com/cocomoff/SampleEinsum

# 行列積の比較

dim1を30に固定して、dim2を変化させた場合の計算時間を計測します。Python側は**timeit**を、Julia側は**tic()**して**toq()**した結果を計算時間と見なしています（これで良いのでしょうか？）

[import:3-15, time.jl](../src/time.jl)

結果です。噂通り、高次元に対してJuliaの優位性が出てきます(もちろん、だからといってJuliaが素晴らしい！というつもりはないですが)。

![figure](https://github.com/cocomoff/SampleEinsum/blob/master/compare.png?raw=true)

# 実装上の話

numpyではOKだったけど、JuliaではOKじゃなかった例を示します（僕の実装のせいかもしれませんが）。まずはpythonではOKだったコードです。このようにPythonのnp.einsumでは、A[0]・A[1]・A[2]のような例を暗黙的に(A[0, i]・A[1, i]・A[2, i]のこと)入力することが出来ます。

[import:8-15, det.py](../src/det.py)

一方で、これに類することを実行するに、PythonでA[0]と実装するところを**A1 = A[:, 1]**などと切り出してから、それを指定する必要があります。これは実装上、numpyではeinsumにおいて"ij->k"など、計算を文字列で指定しているのに対して、Juliaでは与えられた式をExprで格納して、それをパースしているため、インデクス(Pythonだと0、Juliaだと1)の型がSymbol型じゃないから起きます。先に述べた通り、ベクトルで切り出すと一応回避できます(他にも方法がありそうです)。

[import:10-15, det.jl](../src/det.jl)