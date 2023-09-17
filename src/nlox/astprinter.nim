# Stdlib imports
import std/strformat

# Internal imports
import ./tostringobject, ./types

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
  if isNil(expr.value):
    result = "nil"
  else:
    result = toString(expr.value, false)

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
