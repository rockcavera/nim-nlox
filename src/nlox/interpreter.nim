import ./expr, ./token, ./tokentype

proc isTruthy(literal: LiteralValue): bool =
  case literal.kind
  of LitNull:
    result = false
  of LitBoolean:
    result = literal.booleanLit
  else:
    result = true

proc isEqual(a: LiteralValue, b: LiteralValue): bool =
  if a.kind == LitNull:
    if b.kind == LitNull:
      result = true
    else:
      result = false
  else:
    result = a == b

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
    result = LiteralValue(kind: LitNumber, numberLit: -right.numberLit) # I need to see later the behavior for non-numbers
  else:
    result = LiteralValue(kind: LitNull) # You may need another type

method evaluate(expr: Binary): LiteralValue =
  let
    left = evaluate(expr.left)
    right = evaluate(expr.right)

  case expr.operator.kind
  of BangEqual:
    result = LiteralValue(kind: LitBoolean, booleanLit: not isEqual(left, right))
  of EqualEqual:
    result = LiteralValue(kind: LitBoolean, booleanLit: isEqual(left, right))
  of Greater:
    result = LiteralValue(kind: LitBoolean, booleanLit: left.numberLit > right.numberLit)
  of GreaterEqual:
    result = LiteralValue(kind: LitBoolean, booleanLit: left.numberLit >= right.numberLit)
  of Less:
    result = LiteralValue(kind: LitBoolean, booleanLit: left.numberLit < right.numberLit)
  of LessEqual:
    result = LiteralValue(kind: LitBoolean, booleanLit: left.numberLit <= right.numberLit)
  of Minus:
    result = LiteralValue(kind: LitNumber, numberLit: left.numberLit - right.numberLit)
  of Plus:
    if left.kind == LitNumber and right.kind == LitNumber:
      result = LiteralValue(kind: LitNumber, numberLit: left.numberLit - right.numberLit)
    elif left.kind == LitString and right.kind == LitString:
      result = LiteralValue(kind: LitString, stringLit: left.stringLit & right.stringLit)
  of Slash:
    result = LiteralValue(kind: LitNumber, numberLit: left.numberLit / right.numberLit)
  of Star:
    result = LiteralValue(kind: LitNumber, numberLit: left.numberLit * right.numberLit)
  else:
    result = LiteralValue(kind: LitNull) # You may need another type
