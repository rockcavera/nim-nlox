# Internal imports
import ./types

proc newAssign*(name: Token, value: Expr): Assign =
  result = new(Assign)
  result.name = name
  result.value = value

proc newBinary*(left: Expr, operator: Token, right: Expr): Binary =
  result = new(Binary)
  result.left = left
  result.operator = operator
  result.right = right

proc newCall*(callee: Expr, paren: Token, arguments: seq[Expr]): Call =
  result = new(Call)
  result.callee = callee
  result.paren = paren
  result.arguments = arguments

proc newGet*(obj: Expr, name: Token): Get =
  result = new(Get)
  result.obj = obj
  result.name = name

proc newGrouping*(expression: Expr): Grouping =
  result = new(Grouping)
  result.expression = expression

proc newLiteral*(value: Object): Literal =
  result = new(Literal)
  result.value = value

proc newLogical*(left: Expr, operator: Token, right: Expr): Logical =
  result = new(Logical)
  result.left = left
  result.operator = operator
  result.right = right

proc newSet*(obj: Expr, name: Token, value: Expr): Set =
  result = new(Set)
  result.obj = obj
  result.name = name
  result.value = value

proc newSuper*(keyword: Token, `method`: Token): Super =
  result = new(Super)
  result.keyword = keyword
  result.`method` = `method`

proc newThis*(keyword: Token): This =
  result = new(This)
  result.keyword = keyword

proc newUnary*(operator: Token, right: Expr): Unary =
  result = new(Unary)
  result.operator = operator
  result.right = right

proc newVariable*(name: Token): Variable =
  result = new(Variable)
  result.name = name

