# Stdlib imports
import std/tables

# Internal imports
import ./hashes2, ./hashes3, ./interpreter, ./literals, ./logger, ./types

type
  FunctionType = enum
    ## Function type enumerator.
    None, Function, Initializer, Method

  ClassType = enum
    ## Class type enumerator.
    None, Class, Subclass

  Resolver* = object
    ## Stores resolver information.
    # interpreter: Interpreter # It is not necessary. The `Lox` state is already
    # passed.
    scopes: seq[TableRef[String, bool]] # No stack collection in stdlib
      ## A stack of scopes.
    currentFunction: FunctionType
      ## Current function type.
    currentClass: ClassType
      ## Current class type.

# Forward declaration
proc resolve*(lox: var Lox, resolver: var Resolver, statements: seq[Stmt])

proc initResolver*(): Resolver =
  ## Initializes and returns a `Resolver` object.
  # result.interpreter = interpreter
  result.currentFunction = FunctionType.None
  result.currentClass = ClassType.None
  result.scopes = newSeqOfCap[TableRef[String, bool]](8)

proc beginScope(resolver: var Resolver) =
  ## Begins a scope at `resolver`.
  add(resolver.scopes, nil)

proc beginScope(resolver: var Resolver, size: int) =
  ## Begins a scope with size `size` in `resolver`.
  add(resolver.scopes, nil)

  if size > 0:
    resolver.scopes[^1] = newTable[String, bool](size)

proc endScope(resolver: var Resolver) =
  ## Ends a scope in `resolver`.
  setLen(resolver.scopes, len(resolver.scopes) - 1)

proc declare(lox: var Lox, resolver: var Resolver, name: Token) =
  ## Declares the name variable `name` in the outermost scope of `resolver`. If
  ## the same variable is declared in the same scope, an error will be reported.
  if len(resolver.scopes) > 0:
    if isNil(resolver.scopes[^1]):
      resolver.scopes[^1] = newTable[String, bool](2)
    elif hasKey(resolver.scopes[^1], name.lexeme):
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
    if not(isNil(resolver.scopes[i])) and
       hasKey(resolver.scopes[i], name.lexeme):

      expr.hash = hashes2.hash(expr)

      resolve(lox, expr, hi - i)

      break

proc resolveFunction(lox: var Lox, resolver: var Resolver, function: Function,
                     kind: FunctionType) =
  ## Resolve the function’s body.
  let enclosingFunction = resolver.currentFunction

  resolver.currentFunction = kind

  beginScope(resolver, len(function.params))

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
  if not(len(resolver.scopes) == 0) and not(isNil(resolver.scopes[^1])) and
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

method resolve(expr: Get, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Get` expression.
  resolve(expr.obj, resolver, lox)

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

method resolve(expr: Set, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Set` expression.
  resolve(expr.value, resolver, lox)
  resolve(expr.obj, resolver, lox)

method resolve(expr: Super, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Super` expression. Reports error if "super" is used outside of
  ## a class or in a class with no superclass.
  if resolver.currentClass == ClassType.None:
    error(lox, expr.keyword, "Can't use 'super' outside of a class.")
  elif resolver.currentClass != ClassType.Subclass:
    error(lox, expr.keyword, "Can't use 'super' in a class with no superclass.")

  resolveLocal(lox, resolver, expr, expr.keyword)

method resolve(expr: This, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `This` expression. Reports error if "this" is used outside of a
  ## class.
  if resolver.currentClass == ClassType.None:
    error(lox, expr.keyword, "Can't use 'this' outside of a class.")
  else:
    resolveLocal(lox, resolver, expr, expr.keyword)

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

method resolve(stmt: Class, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Class` statement. Reports error if a class inherits itself.
  let enclosingClass = resolver.currentClass

  resolver.currentClass = ClassType.Class

  declare(lox, resolver, stmt.name)

  define(resolver, stmt.name)

  let notIsNilStmtSuperclass = not isNil(stmt.superclass)

  if notIsNilStmtSuperclass:
    if stmt.name.lexeme == stmt.superclass.name.lexeme:
      error(lox, stmt.superclass.name, "A class can't inherit from itself.")

    resolver.currentClass = ClassType.Subclass

    resolve(stmt.superclass, resolver, lox)

    beginScope(resolver, 1)

    resolver.scopes[^1][newStringWithHash("super")] = true

  beginScope(resolver, 1)

  resolver.scopes[^1][newStringWithHash("this")] = true

  for `method` in stmt.methods:
    var declaration = FunctionType.Method

    if `method`.name.lexeme.data == "init":
      declaration = FunctionType.Initializer

    resolveFunction(lox, resolver, `method`, declaration)

  endScope(resolver)

  if notIsNilStmtSuperclass:
    endScope(resolver)

  resolver.currentClass = enclosingClass

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

method resolve(stmt: types.Return, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `Return` statement. Reports an error if "return" is called from
  ## top-level code or tries to return a value from an initializer.
  if resolver.currentFunction == FunctionType.None:
    error(lox, stmt.keyword, "Can't return from top-level code.")

  if not isNil(stmt.value):
    if resolver.currentFunction == FunctionType.Initializer:
      error(lox, stmt.keyword, "Can't return a value from an initializer.")

    resolve(stmt.value, resolver, lox)

method resolve(stmt: While, resolver: var Resolver, lox: var Lox) =
  ## Resolves a `While` statement.
  resolve(stmt.condition, resolver, lox)
  resolve(stmt.body, resolver, lox)

proc resolve*(lox: var Lox, resolver: var Resolver, statements: seq[Stmt]) =
  ## Resolves `statements`.
  for statement in statements:
    resolve(statement, resolver, lox)
