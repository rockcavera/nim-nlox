# Stdlib imports
import std/hashes

# Internal imports
import ./types

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

proc hash(literal: Object): Hash =
  ## Returns a `Hash` of the `Object`.
  if isNil(literal): # prevents `NilAccessDefect`
    result = hash(0)
  else:
    result = toHash(literal)

proc hash*(token: Token): Hash =
  ## Returns a `Hash` of the `Token`.
  result = hash(token.kind) !& hash(token.literal) !& token.lexeme.hash !&
           hash(token.line)
  result = !$result

method hash*(expr: Expr): Hash {.base.} =
  ## Base method that raises `CatchableError` exception when `expr` has not had
  ## its method implemented.
  let msg = "Method without implementation override"
  raise newException(CatchableError, msg)

method hash*(expr: Assign): Hash =
  ## Returns a `Hash` of an `Assign` expression.
  result = hash(expr.name) !& hash(expr.value)
  result = !$result

method hash*(expr: Binary): Hash =
  ## Returns a `Hash` of a `Binary` expression.
  result = hash(expr.left) !& hash(expr.operator) !& hash(expr.right)
  result = !$result

method hash*(expr: Call): Hash =
  ## Returns a `Hash` of a `Call` expression.
  result = hash(expr.callee) !& hash(expr.paren) !& hash(expr.arguments)
  result = !$result

method hash*(expr: Get): Hash =
  ## Returns a `Hash` of a `Get` expression.
  result = hash(expr.obj) !& hash(expr.name)
  result = !$result

method hash*(expr: Grouping): Hash =
  ## Returns a `Hash` of a `Grouping` expression.
  hash(expr.expression)

method hash*(expr: Literal): Hash =
  ## Returns a `Hash` of a `Literal` expression.
  hash(expr.value)

method hash*(expr: Logical): Hash =
  ## Returns a `Hash` of a `Logical` expression.
  result = hash(expr.left) !& hash(expr.operator) !& hash(expr.right)
  result = !$result

method hash*(expr: Set): Hash =
  ## Returns a `Hash` of a `Set` expression.
  result = hash(expr.obj) !& hash(expr.name) !& hash(expr.value)
  result = !$result

method hash*(expr: Super): Hash =
  ## Returns a `Hash` of a `Super` expression.
  result = hash(expr.keyword) !& hash(expr.`method`)
  result = !$result

method hash*(expr: This): Hash =
  ## Returns a `Hash` of a `This` expression.
  hash(expr.keyword)

method hash*(expr: Unary): Hash =
  ## Returns a `Hash` of an `Unary` expression.
  result = hash(expr.operator) !& hash(expr.right)
  result = !$result

method hash*(expr: Variable): Hash =
  ## Returns a `Hash` of a `Variable` expression.
  hash(expr.name)
