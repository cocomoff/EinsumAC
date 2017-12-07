# 実装詳細補足

Einsum.jlは300行程度の実装になっているので、この実装を見ながらJuliaにあるメタプログラミング機能や、実装で使われているちょっとした機能を紹介します。

## Expr型
メタプログラミングに使います。Juliaではプログラムのコード自体をデータ構造として持つことができるので、これを利用して@einsumマクロで入力された計算式を格納します。

- <a href='http://bicycle1885.hatenablog.com/entry/2015/08/15/143620' target='_blank'>Juliaのシンボルとは? - りんごがでている</a>
- <a href='https://docs.julialang.org/en/stable/manual/metaprogramming/' target='_blank'>Metaprogramming · The Julia Language</a>

実際に見てみましょう。@einsumマクロの実体**_einsum**関数です。コードブロックの引数はargsで取ってきます。

[import:20-25, Einsum.me.jl](../src/Einsum.jl)

よってEinsum.jlの中身では、与えられた式をExpr型のデータ構造として解析し、計算を行っていると分かります。REPLでも見てみます。Expr型の式は**eval**を利用すると評価できます。例は最初に使った行列積の例で、Expr部分を見てみます。

```julia
julia> expr = :(AB[i, k] = A[i, j] * B[j, k])
:(AB[i,k] = A[i,j] * B[j,k])

# 第一引数を見てみる
julia> expr1 = expr.args[1]

# dumpで中身を可視化 (xdumpはdeprecated)
julia> dump(expr1)
Expr
  head: Symbol ref
  args: Array{Any}((3,))
    1: Symbol AB
    2: Symbol i
    3: Symbol k
  typ: Any

# 実際にevalしてみる
julia> A = zeros(2, 2, 2); i = 1; j = 1; k = 1;

julia> eval(expr1)
0.0 # zeros(2, 2, 2)の[1, 1, 1]要素
```

Juliaが提供しているメタプログラミングの枠組みは、ちょっとした計算式の展開などに使えそうです。


## quote

もう少し読み進めると、**quote**という構文が使われます。例えば計算式を最終的に返すところで出てきます。これはExpr型を式で明示的に書くことなく、コードブロックをExpr型に解析した形で返してくれます。

[import:173-180, Einsum.me.jl](../src/Einsum.jl)

## eltype

コレクションに格納されているデータ型を決定します。今回の例だと与えられた引数の行列BやCがIntなのかFloatなのかを判定して、データを格納する行列Aを定義するときに使います。

```julia
julia> B = rand(2, 2); eltype(B)
Float64
```

## promote_type

与えられた2つの型から、情報損失が少ない方を返します。簡単に言うとIntとFloatが与えられたとき、Float側に揃えるために使ってます。

```julia
julia> promote_type(Int64, Float64)
Float64
```


## esc

後半で出てきます@macroの中で外部の変数に対して影響を与えるために使っています（解析した結果を外部で定義した変数に書き込む）。メタプログラミングの解説にある、簡単な例を見てみるとこれをマクロ内で使っている雰囲気が分かります。実行結果はesc無しだと1が、escありだと0が出力されます。Hygieneという概念に関係がありそうです（無知）。

[import, macro_esc.jl](../src/macro_esc.jl)

## macroexpand
具体的にマクロがどのように展開されるか分かります。このあたりはLispリスペクトなんでしょうか？実際に行列積を計算させたマクロの展開を見てみます。for文が速いと噂されているJuliaなので、中身は普通のfor文です

[import, macroexpand.txt](../src/macroexpand.txt)

# オマケ
Einsum.jlについての補足です。左辺の行列インデクスに出てこない右辺の行列インデクスについて和を取るという仕組みが実装されていました。動作確認してみましょう。

```julia
A = zeros(2)
B = rand(2, 2)
C = rand(2, 2)
@einsum A[i] = B[i, j] * C[j, k]  # kが浮いている
```

これはCの行方向が浮いている状態なので、Cを行方向に和したベクトルで置き換えられます。つまり上のAは下のA2と同じ結果になります。

```julia
C2 = sum(C, 2)
@einsum A[i] = B[i, j] * C2[j]
```