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

proc resolveFunction(lox: var Lox, resolver: var Resolver, function: Function) =
  beginScope(resolver)

  for param in function.params:
    declare(resolver, param)

    define(resolver, param)

  resolve(lox, function.body)

  endScope(resolver)

method resolve(expr: Expr, resolver: var Resolver, lox: var Lox) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method resolve(expr: Variable, resolver: var Resolver, lox: var Lox) =
  if not(len(resolver.scopes) == 0) and (resolver.scopes[^1][expr.name.lexeme] == false):
    error(lox, expr.name, "Can't read local variable in its own initializer.")

  resolveLocal(resolver, expr, expr.name)

method resolve(expr: Assign, resolver: var Resolver, lox: var Lox) =
  resolve(expr.value, resolver, lox)

  resolveLocal(resolver, expr, expr.name)

method resolve(expr: Binary, resolver: var Resolver, lox: var Lox) =
  resolve(expr.left, resolver, lox)
  resolve(expr.right, resolver, lox)

method resolve(expr: Call, resolver: var Resolver, lox: var Lox) =
  resolve(expr.callee, resolver, lox)

  for argument in expr.arguments:
    resolve(argument, resolver, lox)

method resolve(expr: Grouping, resolver: var Resolver, lox: var Lox) =
  resolve(expr.expression, resolver, lox)

method resolve(expr: Literal, resolver: var Resolver, lox: var Lox) =
  discard

method resolve(expr: Logical, resolver: var Resolver, lox: var Lox) =
  resolve(expr.left, resolver, lox)
  resolve(expr.right, resolver, lox)

method resolve(expr: Unary, resolver: var Resolver, lox: var Lox) =
  resolve(expr.right, resolver, lox)

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

method resolve(stmt: Function, resolver: var Resolver, lox: var Lox) =
  declare(resolver, stmt.name)

  define(resolver, stmt.name)

  resolveFunction(lox, resolver, stmt)

method resolve(stmt: Expression, resolver: var Resolver, lox: var Lox) =
  resolve(stmt.expression, resolver, lox)

method resolve(stmt: If, resolver: var Resolver, lox: var Lox) =
  resolve(stmt.condition, resolver, lox)
  resolve(stmt.thenBranch, resolver, lox)

  if not isNil(stmt.elseBranch):
    resolve(stmt.elseBranch, resolver, lox)

method resolve(stmt: Print, resolver: var Resolver, lox: var Lox) =
  resolve(stmt.expression, resolver, lox)

method resolve(stmt: stmt.Return, resolver: var Resolver, lox: var Lox) =
  if not isNil(stmt.value):
    resolve(stmt.value, resolver, lox)

method resolve(stmt: While, resolver: var Resolver, lox: var Lox) =
  resolve(stmt.condition, resolver, lox)
  resolve(stmt.body, resolver, lox)

proc resolve*(lox: var Lox, statements: seq[Stmt]) =
  var resolver = initResolver(lox.interpreter)

  for statement in statements:
    resolve(statement, resolver, lox)
