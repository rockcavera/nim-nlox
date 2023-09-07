import std/tables

import ./expr, ./logger, ./stmt, ./types

type
  Resolver* = object
    interpreter: Interpreter
    scopes: seq[Table[string, bool]] # No stack collection in stdlib

# Forward declaration
proc resolve*(lox: var Lox, statements: seq[Stmt])

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

proc resolveLocal(resolver: var Resolver, expr: Expr, name: Token) =
  let hi = high(resolver.scopes)

  for i in countdown(hi, 0):
    if hasKey(resolver.scopes[i], name.lexeme):
      resolve(resolver.interpreter, hi - i)
      break

method resolve(expr: Expr, resolver: var Resolver, lox: var Lox) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method resolve(expr: Variable, resolver: var Resolver, lox: var Lox) =
  if not(len(resolver.scopes) == 0) and (resolver.scopes[^1][expr.name.lexeme] == false):
    error(lox, expr.name, "Can't read local variable in its own initializer.")

  resolveLocal(resolver, expr, expr.name)

method resolve(expr: Assign, resolver: var Resolver, lox: var Lox) =
  resolve(expr.value, resolver, lox)

  resolveLocal(resolver, expr, expr.name)

method resolve(stmt: Stmt, resolver: var Resolver, lox: var Lox) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method resolve(stmt: Block, resolver: var Resolver, lox: var Lox) =
  beginScope(resolver)

  resolve(lox, stmt.statements)

  endScope(resolver)

method resolve(stmt: Var, resolver: var Resolver, lox: var Lox) =
  declare(resolver, stmt.name)

  if not isNil(stmt.initializer):
    resolve(stmt.initializer, resolver, lox)

  define(resolver, stmt.name)

proc resolve*(lox: var Lox, statements: seq[Stmt]) =
  var resolver = initResolver(lox.interpreter)

  for statement in statements:
    resolve(statement, resolver, lox)
