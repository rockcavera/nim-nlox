# Internal imports
import ./types

proc newAssign*(name: Token, value: Expr): Assign =
  Assign(name: name, value: value)

proc newBinary*(left: Expr, operator: Token, right: Expr): Binary =
  Binary(left: left, operator: operator, right: right)

proc newCall*(callee: Expr, paren: Token, arguments: seq[Expr]): Call =
  Call(callee: callee, paren: paren, arguments: arguments)

proc newGet*(obj: Expr, name: Token): Get =
  Get(obj: obj, name: name)

proc newGrouping*(expression: Expr): Grouping =
  Grouping(expression: expression)

proc newLiteral*(value: Object): Literal =
  Literal(value: value)

proc newLogical*(left: Expr, operator: Token, right: Expr): Logical =
  Logical(left: left, operator: operator, right: right)

proc newSet*(obj: Expr, name: Token, value: Expr): Set =
  Set(obj: obj, name: name, value: value)

proc newSuper*(keyword: Token, `method`: Token): Super =
  Super(keyword: keyword, `method`: `method`)

proc newThis*(keyword: Token): This =
  This(keyword: keyword)

proc newUnary*(operator: Token, right: Expr): Unary =
  Unary(operator: operator, right: right)

proc newVariable*(name: Token): Variable =
  Variable(name: name)
