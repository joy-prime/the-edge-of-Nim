import macros, unittest

template reject*(x) =
  static: doAssert(not compiles(x))

