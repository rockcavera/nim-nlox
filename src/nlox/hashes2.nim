# Stdlib imports
import std/hashes

# Internal imports
import ./expr, ./types

method toHash(literal: Object): Hash {.base.} =
  ## Base method that raises `CatchableError` exception when `literal` has not
  ## had its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method toHash(literal: Boolean): Hash =
  ## Returns a `Hash` of the `Boolean` object.
  hash(literal.data)

method toHash(literal: Number): Hash =
  ## Returns a `Hash` of the `Number` object.
  hash(literal.data)

method toHash(literal: String): Hash =
  ## Returns a `Hash` of the `String` object.
  hash(literal.data)

proc hash*(literal: Object): Hash =
  ## Returns a `Hash` of the `Object`.
  if isNil(literal): # prevents `NilAccessDefect`
    result = hash(0)
  else:
    result = toHash(literal)

method hash*(expr: Expr): Hash {.base.} =
  ## Base method that raises `CatchableError` exception when `expr` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method hash*(expr: Assign): Hash =
  ## Returns a `Hash` of an `Assign` expression.
  hash(expr.name) !& hash(expr.value)

method hash*(expr: Binary): Hash =
  ## Returns a `Hash` of a `Binary` expression.
  hash(expr.left) !& hash(expr.operator) !& hash(expr.right)

method hash*(expr: Call): Hash =
  ## Returns a `Hash` of a `Call` expression.
  hash(expr.callee) !& hash(expr.paren) !& hash(expr.arguments)

method hash*(expr: Get): Hash =
  hash(expr.obj) !& hash(expr.name)

method hash*(expr: Grouping): Hash =
  ## Returns a `Hash` of a `Grouping` expression.
  hash(expr.expression)

method hash*(expr: Literal): Hash =
  ## Returns a `Hash` of a `Literal` expression.
  hash(expr.value)

method hash*(expr: Logical): Hash =
  ## Returns a `Hash` of a `Logical` expression.
  hash(expr.left) !& hash(expr.operator) !& hash(expr.right)

method hash*(expr: Set): Hash =
  hash(expr.obj) !& hash(expr.name) !& hash(expr.value)

method hash*(expr: This): Hash =
  hash(expr.keyword)

method hash*(expr: Unary): Hash =
  ## Returns a `Hash` of an `Unary` expression.
  hash(expr.operator) !& hash(expr.right)

method hash*(expr: Variable): Hash =
  ## Returns a `Hash` of a `Variable` expression.
  hash(expr.name)
