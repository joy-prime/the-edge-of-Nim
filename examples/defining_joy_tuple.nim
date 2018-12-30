import macros, tables

type JoyField = tuple[fieldName: string, typeAst: NimNode]

macro declareJoyField(name: untyped): untyped =
  expectKind(name, nnkIdent)
  nnkVarSection.newTree(
    nnkIdentDefs.newTree(
      nnkPragmaExpr.newTree(
        newIdentNode($name),
        nnkPragma.newTree(
          newIdentNode("compileTime")
        )
      ),
      newIdentNode("JoyField"),
      newEmptyNode()
    )
  )

macro defineJoyField(jf: static[var JoyField], 
                     fieldName, typ: untyped): untyped =
  jf = (fieldName: $fieldName, typeAst: typ)
  newEmptyNode()

template joyField(fieldName, typ: untyped): untyped =
  declareJoyField(fieldName)
  defineJoyField(fieldName, fieldName, typ)

macro joyTuple(tupleTypeName: untyped, 
               jf: static[var JoyField]): typed = 
  let fieldNameAst = newIdentNode(jf.fieldName)
  let typeAst = jf.typeAst
  quote:
    type `tupleTypeName` = tuple[`fieldNameAst`: `typeAst`]

joyField(firstName, string)
joyTuple(Person, firstName)

let p: Person = (firstName: "Sybil")

echo p.firstName


  
