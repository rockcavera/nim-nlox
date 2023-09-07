import std/hashes

import ./expr, ./types

method toHash(literal: Object): Hash {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method toHash(literal: Boolean): Hash =
  hash(literal.data)

method toHash(literal: Number): Hash =
  hash(literal.data)

method toHash(literal: String): Hash =
  hash(literal.data)

proc hash*(literal: Object): Hash =
  if isNil(literal): # prevents `NilAccessDefect`
    result = hash(0)
  else:
    result = toHash(literal)

method hash*(expr: Expr): Hash {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method hash*(expr: Assign): Hash =
  hash(expr.name) !& hash(expr.value)

method hash*(expr: Binary): Hash =
  hash(expr.left) !& hash(expr.operator) !& hash(expr.right)

method hash*(expr: Call): Hash =
  hash(expr.callee) !& hash(expr.paren) !& hash(expr.arguments)

method hash*(expr: Grouping): Hash =
  hash(expr.expression)

method hash*(expr: Literal): Hash =
  hash(expr.value)

method hash*(expr: Logical): Hash =
  hash(expr.left) !& hash(expr.operator) !& hash(expr.right)

method hash*(expr: Unary): Hash =
  hash(expr.operator) !& hash(expr.right)

method hash*(expr: Variable): Hash =
  hash(expr.name)
