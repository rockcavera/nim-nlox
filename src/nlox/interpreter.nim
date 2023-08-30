import std/[math, strutils]

import ./expr, ./logger, ./literals, ./runtimeerror, ./token, ./tokentype

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

proc checkNumberOperand(operator: Token, operand: LiteralValue) =
  if operand.kind != LitNumber:
    raise newRuntimeError(operator, "Operand must be a number.")

proc checkNumberOperands(operator: Token, left: LiteralValue, right: LiteralValue) =
  if left.kind != LitNumber or right.kind != LitNumber:
    raise newRuntimeError(operator, "Operands must be numbers.")

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
    checkNumberOperand(expr.operator, right)

    result = initLiteralNumber(-right.numberLit)
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
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralBoolean(left.numberLit > right.numberLit)
  of GreaterEqual:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralBoolean(left.numberLit >= right.numberLit)
  of Less:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralBoolean(left.numberLit < right.numberLit)
  of LessEqual:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralBoolean(left.numberLit <= right.numberLit)
  of Minus:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralNumber(left.numberLit - right.numberLit)
  of Plus:
    if left.kind == LitNumber and right.kind == LitNumber:
      result = initLiteralNumber(left.numberLit - right.numberLit)
    elif left.kind == LitString and right.kind == LitString:
      result = initLiteralString(left.stringLit & right.stringLit)
    else:
      raise newRuntimeError(expr.operator, "Operands must be two numbers or two strings.")
  of Slash:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralNumber(left.numberLit / right.numberLit)
  of Star:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralNumber(left.numberLit * right.numberLit)
  else:
    result = initLiteral() # You may need another type

proc stringify(literal: LiteralValue): string =
  case literal.kind
  of LitNull:
    result = "nil"
  of LitNumber:
    result = $literal.numberLit

    if endsWith(result, ".0"):
      setLen(result, len(result) - 2)
  of LitString:
    result = literal.stringLit
  of LitBoolean:
    result = $literal.booleanLit

proc interpret*(expression: Expr) =
  try:
    let value = evaluate(expression)

    echo stringify(value)
  except RuntimeError as error:
    runtimeError(error)
