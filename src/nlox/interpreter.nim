import ./expr, ./token, ./tokentype

method evaluate(expr: Expr): LiteralValue {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method evaluate(expr: Literal): LiteralValue =
  expr.value

method evaluate(expr: Grouping): LiteralValue =
  evaluate(expr.expression)

method evaluate(expr: Unary): LiteralValue =
  let right = evaluate(expr.right)

  case expr.operator.kind
  of Bang:
    result = LiteralValue(kind: LitBoolean, booleanLit: not isTruthy(right))
  of Minus:
    result = LiteralValue(kind: LitNumber, numberLit: -right.numberLit)
  else:
    result = LiteralValue(kind: LitNull) # You may need another type
