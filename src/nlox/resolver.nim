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

method resolve(expr: Expr, resolver: var Resolver) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method resolve(stmt: Stmt, resolver: var Resolver) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method resolve(stmt: Block, resolver: var Resolver) =
  beginScope(resolver)

  resolve(stmt.statements)

  endScope(resolver)

proc resolve(statements: seq[Stmt]) =
  var
    interpreter: Interpreter
    resolver = initResolver(interpreter)

  for statement in statements:
    resolve(statement, resolver)
