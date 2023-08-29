import std/strformat

import ./expr, ./token, ./tokentype

proc parenthesize(name: string, exprs: varargs[Expr]): string

method print(expr: Expr): string {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method print(expr: Binary): string =
  parenthesize(expr.operator.lexeme, expr.left, expr.right)

method print(expr: Grouping): string =
  parenthesize("group", expr.expression)

method print(expr: Literal): string =
  $expr.value

method print(expr: Unary): string =
  parenthesize(expr.operator.lexeme, expr.right)

proc parenthesize(name: string, exprs: varargs[Expr]): string =
  result = fmt"({name}"

  for expr in exprs:
    add(result, fmt" {print(expr)}")

  add(result, ')')

when isMainModule:
  proc main() =
    let expression = newBinary(
      newUnary(
        Token(kind: Minus, literal: LiteralValue(kind: LitNone), lexeme: "-", line: 1),
        newLiteral(LiteralValue(kind: LitNumber, numberLit: 123))),
      Token(kind: Star, literal: LiteralValue(kind: LitNone), lexeme: "*", line: 1),
      newGrouping(
        newLiteral(LiteralValue(kind: LitNumber, numberLit: 45.67))))

    echo print(expression)

  main() # Expected: (* (- 123) (group 45.67))
