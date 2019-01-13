import macros, tables

type Attribute = tuple[name: string, typeAst: NimNode]

macro declareAttribute(name: untyped): untyped =
  expectKind(name, nnkIdent)
  nnkVarSection.newTree(
    nnkIdentDefs.newTree(
      nnkPragmaExpr.newTree(
        newIdentNode($name),
        nnkPragma.newTree(
          newIdentNode("compileTime")
        )
      ),
      newIdentNode("Attribute"),
      newEmptyNode()
    )
  )

macro defineAttribute(attr: static[var Attribute],
                      name, typ: untyped): untyped =
  attr = (name: $name, typeAst: typ)
  newEmptyNode()

template attribute(name, typ: untyped): untyped =
  declareAttribute(name)
  defineAttribute(name, name, typ)

macro data(tupleTypeName: untyped,
           attr: static[Attribute]): typed =
  let nameAst = newIdentNode(attr.name)
  let typeAst = attr.typeAst
  quote:
    type `tupleTypeName` = tuple[`nameAst`: `typeAst`]

attribute(firstName, string)
data(Person, firstName)

let p: Person = (firstName: "Sybil")
echo p.firstName