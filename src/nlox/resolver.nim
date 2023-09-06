import std/tables

import ./expr, ./stmt, ./types

type
  Resolver* = object
    interpreter: Interpreter
    scopes: seq[Table[string, bool]] # No stack collection in stdlib

# Forward declaration
proc resolve(statements: seq[Stmt])

proc initResolver*(interpreter: Interpreter): Resolver =
  result.interpreter = interpreter

proc beginScope(resolver: var Resolver) =
  add(resolver.scopes, initTable[string, bool]())

proc endScope(resolver: var Resolver) =
  setLen(resolver.scopes, len(resolver.scopes) - 1)

proc declare(resolver: var Resolver, name: Token) =
  if len(resolver.scopes) > 0:
    resolver.scopes[^1][name.lexeme] = false

proc define(resolver: var Resolver, name: Token) =
  if len(resolver.scopes) > 0:
    resolver.scopes[^1][name.lexeme] = true

method resolve(expr: Expr, resolver: var Resolver) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method resolve(stmt: Stmt, resolver: var Resolver) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method resolve(stmt: Block, resolver: var Resolver) =
  beginScope(resolver)

  resolve(stmt.statements)

  endScope(resolver)

method resolve(stmt: Var, resolver: var Resolver) =
  declare(resolver, stmt.name)

  if not isNil(stmt.initializer):
    resolve(stmt.initializer, resolver)

  define(resolver, stmt.name)

proc resolve(statements: seq[Stmt]) =
  var
    interpreter: Interpreter
    resolver = initResolver(interpreter)

  for statement in statements:
    resolve(statement, resolver)
