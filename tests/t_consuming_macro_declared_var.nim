import unittest, helpers, macros

template declareAnswer1(a: untyped): untyped =
  # Because of template hygiene, `answer1` is not injected 
  # into the instantiation scope.
  var answer1: int = a

reject:
  test "consume a template-generated local var declaration":
    declareAnswer1(42)
    answer1.inc(1) # Error: undeclared identifier: 'answer1'
    doAssert answer1 == 43

template declareAnswer1b(a: untyped): untyped {.dirty.} =
  var answer1b: int = a

test "consume a dirty-template-generated local var declaration":
  declareAnswer1b(42)
  answer1b.inc(1) # Error: undeclared identifier: 'answer'
  doAssert answer1b == 43

macro declareAnswer1c(a: untyped): untyped =
  nnkVarSection.newTree(
    nnkIdentDefs.newTree(
      newIdentNode("answer1c"),
      newIdentNode("int"),
      a
    )
  )

test "consume a template-generated local var declaration":
  declareAnswer1c(42)
  answer1c.inc(1)
  doAssert answer1c == 43
    
template declareAnswer2(a: untyped): untyped =
  var answer2: int = `a`
