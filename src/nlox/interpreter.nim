import ./expr, ./token

method evaluate(expr: Expr): LiteralValue {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method evaluate(expr: Literal): LiteralValue =
  expr.value

method evaluate(expr: Grouping): LiteralValue =
  evaluate(expr.expression)
