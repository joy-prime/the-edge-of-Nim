import macros, unittest

macro doesnt_compile*(x: untyped): untyped =
  let r = x.repr.newStrLitNode
  quote:
    test "This shouldn't compile: " & `r`:
      check(not compiles(`x`))
