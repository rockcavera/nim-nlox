# Stdlib imports
import std/tables

# Internal imports
import ./expr, ./interpreter, ./logger, ./stmt, ./types

type
  FunctionType = enum
    ## Function type enumerator.
    None, Function

  Resolver* = object
    ## Stores resolver information.
    # interpreter: Interpreter # It is not necessary. The `Lox` state is already
    # passed.
    scopes: seq[Table[string, bool]] # No stack collection in stdlib
      ## A stack of scopes.
    currentFunction: FunctionType
      ## Current function type.

# Forward declaration
proc resolve*(lox: var Lox, resolver: var Resolver, statements: seq[Stmt])

proc initResolver*(): Resolver =
  ## Initializes and returns a `Resolver` object.
  # result.interpreter = interpreter
  result.currentFunction = FunctionType.None

proc beginScope(resolver: var Resolver) =
  ## Begins a scope at `resolver`.
  add(resolver.scopes, initTable[string, bool]())

proc endScope(resolver: var Resolver) =
  ## Ends a scope in `resolver`.
  setLen(resolver.scopes, len(resolver.scopes) - 1)

proc declare(lox: var Lox, resolver: var Resolver, name: Token) =
  ## Declares the name variable `name` in the outermost scope of `resolver`. If
  ## the same variable is declared in the same scope, an error will be reported.
  if len(resolver.scopes) > 0:
    if hasKey(resolver.scopes[^1], name.lexeme):
      error(lox, name, "Already a variable with this name in this scope.")

    resolver.scopes[^1][name.lexeme] = false

proc define(resolver: var Resolver, name: Token) =
  ## Defines in the scope of `resolver` that the variable `name` is initialized
  ## and available for use.
  if len(resolver.scopes) > 0:
    resolver.scopes[^1][name.lexeme] = true

proc resolveLocal(lox: var Lox, resolver: var Resolver, expr: Expr,
                  name: Token) =
  ## Helper procedure to resolve a local variable.
  let hi = high(resolver.scopes)

  for i in countdown(hi, 0):
    if hasKey(resolver.scopes[i], name.lexeme):
      resolve(lox, expr, hi - i)
      break

proc resolveFunction(lox: var Lox, resolver: var Resolver, function: Function,
                     kind: FunctionType) =
  ## Resolve the function’s body.
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
  ## Base method that raises `CatchableError` exception when `expr` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method resolve(expr: Variable, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Variable` expression. Reports an error if the variable is
  ## declared but not defined.
  if not(len(resolver.scopes) == 0) and
     hasKey(resolver.scopes[^1], expr.name.lexeme) and
     (resolver.scopes[^1][expr.name.lexeme] == false):
    error(lox, expr.name, "Can't read local variable in its own initializer.")

  resolveLocal(lox, resolver, expr, expr.name)

method resolve(expr: Assign, resolver: var Resolver, lox: var Lox) =
  ## Resolves an `Assign` expression.
  resolve(expr.value, resolver, lox)

  resolveLocal(lox, resolver, expr, expr.name)

method resolve(expr: Binary, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Binary` expression.
  resolve(expr.left, resolver, lox)
  resolve(expr.right, resolver, lox)

method resolve(expr: Call, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Call` expression.
  resolve(expr.callee, resolver, lox)

  for argument in expr.arguments:
    resolve(argument, resolver, lox)

method resolve(expr: Grouping, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Grouping` expression.
  resolve(expr.expression, resolver, lox)

method resolve(expr: Literal, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Literal` expression.
  discard

method resolve(expr: Logical, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Logical` expression.
  resolve(expr.left, resolver, lox)
  resolve(expr.right, resolver, lox)

method resolve(expr: Unary, resolver: var Resolver, lox: var Lox) =
  ## Resolves an `Unary` expression.
  resolve(expr.right, resolver, lox)

method resolve(stmt: Stmt, resolver: var Resolver, lox: var Lox) {.base.} =
  ## Base method that raises `CatchableError` exception when `stmt` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method resolve(stmt: Block, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Block` statement.
  beginScope(resolver)

  resolve(lox, resolver, stmt.statements)

  endScope(resolver)

method resolve(stmt: Var, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Var` statement.
  declare(lox, resolver, stmt.name)

  if not isNil(stmt.initializer):
    resolve(stmt.initializer, resolver, lox)

  define(resolver, stmt.name)

method resolve(stmt: Function, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Function` statement.
  declare(lox, resolver, stmt.name)

  define(resolver, stmt.name)

  resolveFunction(lox, resolver, stmt, FunctionType.Function)

method resolve(stmt: Expression, resolver: var Resolver, lox: var Lox) =
  ## Resolves an `Expression` statement.
  resolve(stmt.expression, resolver, lox)

method resolve(stmt: If, resolver: var Resolver, lox: var Lox) =
  ## Resolves an `If` statement.
  resolve(stmt.condition, resolver, lox)
  resolve(stmt.thenBranch, resolver, lox)

  if not isNil(stmt.elseBranch):
    resolve(stmt.elseBranch, resolver, lox)

method resolve(stmt: Print, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Print` statement.
  resolve(stmt.expression, resolver, lox)

method resolve(stmt: stmt.Return, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Return` statement. Report an error if `return` is called in lox
  ## top-level code
  if resolver.currentFunction == FunctionType.None:
    error(lox, stmt.keyword, "Can't return from top-level code.")

  if not isNil(stmt.value):
    resolve(stmt.value, resolver, lox)

method resolve(stmt: While, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `While` statement.
  resolve(stmt.condition, resolver, lox)
  resolve(stmt.body, resolver, lox)

proc resolve*(lox: var Lox, resolver: var Resolver, statements: seq[Stmt]) =
  ## Resolves `statements`.
  for statement in statements:
    resolve(statement, resolver, lox)
