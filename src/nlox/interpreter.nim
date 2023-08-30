import std/math

import ./expr, ./literals, ./token, ./tokentype

proc isTruthy(literal: LiteralValue): bool =
  case literal.kind
  of LitNull:
    result = false
  of LitBoolean:
    result = literal.booleanLit
  else:
    result = true

proc isEqual(a: LiteralValue, b: LiteralValue): bool =
  case a.kind
  of LitNull:
    if b.kind == LitNull:
      result = true
    else:
      result = false
  of LitNumber:
    if b.kind == LitNumber:
      if isNaN(a.numberLit) and isNaN(b.numberLit):
        result = true
      else:
        result = a.numberLit == b.numberLit
    else:
      result = false
  of LitString:
    if b.kind == LitString:
      result = a.stringLit == b.stringLit
    else:
      result = false
  of LitBoolean:
    if b.kind == LitBoolean:
      result = a.booleanLit == b.booleanLit
    else:
      result = false

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
    result = initLiteralBoolean(not isTruthy(right))
  of Minus:
    result = initLiteralNumber(-right.numberLit) # I need to see later the behavior for non-numbers
  else:
    result = initLiteral() # You may need another type

method evaluate(expr: Binary): LiteralValue =
  let
    left = evaluate(expr.left)
    right = evaluate(expr.right)

  case expr.operator.kind
  of BangEqual:
    result = initLiteralBoolean(not isEqual(left, right))
  of EqualEqual:
    result = initLiteralBoolean(isEqual(left, right))
  of Greater:
    result = initLiteralBoolean(left.numberLit > right.numberLit)
  of GreaterEqual:
    result = initLiteralBoolean(left.numberLit >= right.numberLit)
  of Less:
    result = initLiteralBoolean(left.numberLit < right.numberLit)
  of LessEqual:
    result = initLiteralBoolean(left.numberLit <= right.numberLit)
  of Minus:
    result = initLiteralNumber(left.numberLit - right.numberLit)
  of Plus:
    if left.kind == LitNumber and right.kind == LitNumber:
      result = initLiteralNumber(left.numberLit - right.numberLit)
    elif left.kind == LitString and right.kind == LitString:
      result = initLiteralString(left.stringLit & right.stringLit)
  of Slash:
    result = initLiteralNumber(left.numberLit / right.numberLit)
  of Star:
    result = initLiteralNumber(left.numberLit * right.numberLit)
  else:
    result = initLiteral() # You may need another type
