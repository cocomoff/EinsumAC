macro zerox1()
  return :(x = 0)
end

macro zerox2()
  return esc(:(x = 0))
end

function foo()
  x = 1
  @zerox1
  x
end

function bar()
  x = 1
  @zerox2
  x
end

println(foo())
println(bar())