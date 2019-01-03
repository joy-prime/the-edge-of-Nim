import unittest, helpers, macros

type
  Vec[N: static[int], A] = array[N, A]

proc sum[N: static int](v: Vec[N, int]): int =
  for i in 0 ..< N:
    inc(result, v[i])

test "at runtime":
  var three: Vec[3, int] = [1, 2, 3]
  doAssert sum(three) == 6
  reject: # array too small for declared size
    var three: Vec[3, int] = [0, 1]

# During compilation, this code echoes "x=2". But it won't let us use
# ``x`` as an array bound, complaining "Error: cannot evaluate at compile time: x".
static:
  var x: int = 0
  x = 2
  echo "x=", x
  reject: # cannot evaluate at compile time: x
    var a: array[0 .. x, int]

const c = block:
  var x: int = 0
  x = x + 2
  x

static:
  var a: array[0 .. c, int]
  doAssert a.high == 2
  doAssert a[0] == 0
  var two: Vec[c, int] = [0, 1]
  doAssert two[1] == 1

static:
  let x: int = 2
  reject: # cannot evaluate at compile time: x
    var a: array[0 .. x, int]
  # reject: # cannot evaluate at compile time: x
    var two: Vec[x, int] = [0, 1]
  reject: # cannot evaluate at compile time: x
    const c = x
  const c2 = block:
    var y: int = 0
    y = y + 2
    y
  var a2: array[0 .. c2, int]
  reject: # cannot evaluate at compile time: x
    const c3 = id_int(x)
  const c4 = block:
    var y: int = 0
    y = y + 2
    y

static:
  const c = block:
    let x: int = 2
    x
  var a: array[0 .. c, int]
  echo "a[0]=", a[0]
  
  # Compiler crash.
  # SIGSEGV: Illegal storage access. (Attempt to read from nil?)
  # https://github.com/nim-lang/Nim/issues/10108
  #proc deliver_x(): int = x
  #var y2 = deliver_x()
  #reject:
  #  const c5 = deliver_x()
    
proc id_int(x: int): int = x

static:
  const c1: int = 42
  const c2 = id_int(c1)
  const ct1 = (c1, c2)
  const c3 = ct1[0]

  