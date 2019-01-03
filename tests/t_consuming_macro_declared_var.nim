import unittest, helpers, macros

template declareAnswer1(a: untyped): untyped =
  var answer1: int = `a`

reject:
  test "consume a template-generated local var declaration":
    declareAnswer1(42)
    answer1.inc(1) # Error: undeclared identifier: 'answer'
    doAssert answer1 == 43

macro declareAnswer1b(a: untyped): untyped =
  nnkVarSection.newTree(
    nnkIdentDefs.newTree(
      newIdentNode("answer1b"),
      newIdentNode("int"),
      a
    )
  )

test "consume a template-generated local var declaration":
  declareAnswer1b(42)
  answer1b.inc(1)
  doAssert answer1b == 43
    
template declareAnswer2(a: untyped): untyped =
  var answer2: int = `a`

declareAnswer2(42)

reject:
  test "consume a template-generated global var declaration":
    answer2.inc(1) # Error: undeclared identifier: 'answer2'
    doAssert answer2 == 43

template declareAnswer3(a: untyped): untyped =
  var answer3: int = `a`

declareAnswer3(42)

reject:
  static:
    answer3.inc(1) # Error: undeclared identifier: 'answer3'
    doAssert answer3 == 43

macro declareAnswer3b(a: untyped): untyped =
  nnkVarSection.newTree(
    nnkIdentDefs.newTree(
      newIdentNode("answer3b"),
      newIdentNode("int"),
      a
    )
  )

declareAnswer3b(42)

reject:
  static:
    echo "answer3b=", answer3b # Error: cannot evaluate at compile time: answer3b
    doAssert answer3b == 42
        
template declareAnswer4(a: untyped): untyped =
  var answer4 {.compileTime.}: int = `a`

declareAnswer4(42)

reject:
  static:
    answer4.inc(1) # Error: undeclared identifier: 'answer4'
    doAssert answer4 == 43

macro declareAnswer4b(a: untyped): untyped =
  nnkVarSection.newTree(
    nnkIdentDefs.newTree(
      nnkPragmaExpr.newTree(
        newIdentNode("answer4b"),
        nnkPragma.newTree(
          newIdentNode("compileTime")
        )
      ),
      newIdentNode("int"),
      a
    )
  )

declareAnswer4b(42)

static:
  echo "answer4b=", answer4b
  doAssert answer4b == 42

template declareAndUseAnswer5(a: untyped): untyped =
  var answer5: int = `a`
  answer5.inc()
  echo "answer5=", answer5
  doAssert answer5 == 43

declareAndUseAnswer5(42)

macro declareInt(name: untyped): untyped =
  expectKind(name, nnkIdent)
  nnkVarSection.newTree(
    nnkIdentDefs.newTree(
      nnkPragmaExpr.newTree(
        newIdentNode($name),
        nnkPragma.newTree(
          newIdentNode("compileTime")
        )
      ),
      newIdentNode("int"),
      newEmptyNode()
    )
  )

declareInt(answer6)

static:
  echo "answer6=", answer6
  answer6.inc(42)
  doAssert answer6 == 42
