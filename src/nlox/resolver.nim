import std/tables

import ./expr, ./interpreter, ./logger, ./stmt, ./types

type
  FunctionType = enum
    None, Function

  Resolver* = object
    # interpreter: Interpreter # It is not necessary. The `Lox` state is already passed.
    scopes: seq[Table[string, bool]] # No stack collection in stdlib
    currentFunction: FunctionType

# Forward declaration
proc resolve*(lox: var Lox, resolver: var Resolver, statements: seq[Stmt])

proc initResolver*(): Resolver =
  # result.interpreter = interpreter
  result.currentFunction = FunctionType.None

proc beginScope(resolver: var Resolver) =
  add(resolver.scopes, initTable[string, bool]())

proc endScope(resolver: var Resolver) =
  setLen(resolver.scopes, len(resolver.scopes) - 1)

proc declare(lox: var Lox, resolver: var Resolver, name: Token) =
  if len(resolver.scopes) > 0:
    if hasKey(resolver.scopes[^1], name.lexeme):
      error(lox, name, "Already a variable with this name in this scope.")

    resolver.scopes[^1][name.lexeme] = false

proc define(resolver: var Resolver, name: Token) =
  if len(resolver.scopes) > 0:
    resolver.scopes[^1][name.lexeme] = true

proc resolveLocal(lox: var Lox, resolver: var Resolver, expr: Expr, name: Token) =
  let hi = high(resolver.scopes)

  for i in countdown(hi, 0):
    if hasKey(resolver.scopes[i], name.lexeme):
      resolve(lox, expr, hi - i)
      break

proc resolveFunction(lox: var Lox, resolver: var Resolver, function: Function, kind: FunctionType) =
  let enclosingFunction = resolver.currentFunction

  resolver.currentFunction = kind

  beginScope(resolver)

  for param in function.params:
    declare(lox, resolver, param)

    define(resolver, param)

  resolve(lox, resolver, function.body)

  endScope(resolver)

  resolver.currentFunction = enclosingFunction

method resolve(expr: Expr, resolver: var Resolver, lox: var Lox) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method resolve(expr: Variable, resolver: var Resolver, lox: var Lox) =
  if not(len(resolver.scopes) == 0) and (getOrDefault(resolver.scopes[^1], expr.name.lexeme, true) == false):
    error(lox, expr.name, "Can't read local variable in its own initializer.")

  resolveLocal(lox, resolver, expr, expr.name)

method resolve(expr: Assign, resolver: var Resolver, lox: var Lox) =
  resolve(expr.value, resolver, lox)

  resolveLocal(lox, resolver, expr, expr.name)

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

  resolve(lox, resolver, stmt.statements)

  endScope(resolver)

method resolve(stmt: Var, resolver: var Resolver, lox: var Lox) =
  declare(lox, resolver, stmt.name)

  if not isNil(stmt.initializer):
    resolve(stmt.initializer, resolver, lox)

  define(resolver, stmt.name)

method resolve(stmt: Function, resolver: var Resolver, lox: var Lox) =
  declare(lox, resolver, stmt.name)

  define(resolver, stmt.name)

  resolveFunction(lox, resolver, stmt, FunctionType.Function)

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
  if resolver.currentFunction == FunctionType.None:
    error(lox, stmt.keyword, "Can't return from top-level code.")

  if not isNil(stmt.value):
    resolve(stmt.value, resolver, lox)

method resolve(stmt: While, resolver: var Resolver, lox: var Lox) =
  resolve(stmt.condition, resolver, lox)
  resolve(stmt.body, resolver, lox)

proc resolve*(lox: var Lox, resolver: var Resolver, statements: seq[Stmt]) =
  for statement in statements:
    resolve(statement, resolver, lox)
