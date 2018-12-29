template reject(x) =
  static: doAssert(not compiles(x))

static:
  let x: int = 2
  proc deliver_x(): int = x
  var y2 = deliver_x()
  reject:
    const c5 = deliver_x()
    

