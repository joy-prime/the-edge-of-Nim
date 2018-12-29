from strutils import parseInt
from macros import error

type
  Vec[N: static[int], A] = array[N, A]

proc sum[N: static int](v: Vec[N, int]): int =
  for i in 0 ..< N:
    inc(result, v[i])

const numDims = block:
  let configFile = "constant_daisy_chain_config.txt"
  let config = staticRead(configFile)
  if config.len < 1 or
     (config.len == 2 and config[1] != '\n') or
     config[0] < '1' or config[0] > '9':
    error("Invalid value in " & configFile & ": " & config)
  int(config[0]) - int('0')

const total = block:
  var a: array[0 .. numDims - 1, int]
  a[0] = 42
  let v: Vec[numDims, int] = a
  sum(v)

static:
  echo total