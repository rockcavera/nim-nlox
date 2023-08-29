# Stdlib imports
import std/strformat

# Internal imports
import ./expr, ./token, ./tokentype

# Forward declaration
proc parenthesize(name: string, exprs: varargs[Expr]): string

method print*(expr: Expr): string {.base.} =
  ## Base method that raises `CatchableError` exception when `expr` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method print*(expr: Binary): string =
  ## Returns a `string` representing the expression `expr`.
  parenthesize(expr.operator.lexeme, expr.left, expr.right)

method print*(expr: Grouping): string =
  ## Returns a `string` representing the expression `expr`.
  parenthesize("group", expr.expression)

method print*(expr: Literal): string =
  ## Returns a `string` representing the expression `expr`.
  $expr.value

method print*(expr: Unary): string =
  ## Returns a `string` representing the expression `expr`.
  parenthesize(expr.operator.lexeme, expr.right)

proc parenthesize(name: string, exprs: varargs[Expr]): string =
  ## Returns a `string`, which encloses `name` and the subexpressions `exprs` in
  ## parentheses. It is a helper procedure of `print()`.
  result = fmt"({name}"

  for expr in exprs:
    add(result, fmt" {print(expr)}")

  add(result, ')')

# This may be removed in the future as it only serves to verify the above code.
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
