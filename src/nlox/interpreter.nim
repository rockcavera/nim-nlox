# Stdlib imports
import std/[math, strutils]

# Internal imports
import ./environment, ./expr, ./logger, ./literals, ./runtimeerror, ./stmt,
       ./token, ./tokentype

# Forward declaration
proc execute(stmt: Stmt)

proc isTruthy(literal: LiteralValue): bool =
  ## Transforms the `literal` object into a boolean type and returns it.
  case literal.kind
  of LitNull:
    result = false
  of LitBoolean:
    result = literal.booleanLit
  else:
    result = true

proc isEqual(a: LiteralValue, b: LiteralValue): bool =
  ## Returns `true` if objects `a` and `b` are equal. Otherwise, it returns
  ## `false`.
  case a.kind
  of LitNull:
    if b.kind == LitNull:
      result = true
    else:
      result = false
  of LitNumber:
    if b.kind == LitNumber:
      if isNaN(a.numberLit) and isNaN(b.numberLit):
        result = true
      else:
        result = a.numberLit == b.numberLit
    else:
      result = false
  of LitString:
    if b.kind == LitString:
      result = a.stringLit == b.stringLit
    else:
      result = false
  of LitBoolean:
    if b.kind == LitBoolean:
      result = a.booleanLit == b.booleanLit
    else:
      result = false

proc checkNumberOperand(operator: Token, operand: LiteralValue) =
  ## Checks if `operand` is a number, and if it is, it does nothing. Otherwise,
  ## it raises a `RuntimeError`.
  if operand.kind != LitNumber:
    raise newRuntimeError(operator, "Operand must be a number.")

proc checkNumberOperands(operator: Token, left: LiteralValue,
                         right: LiteralValue) =
  ## Checks if the operands `left` and `right` are numbers, and if they are, it
  ## does nothing. Otherwise, it raises a `RuntimeError`.
  if left.kind != LitNumber or right.kind != LitNumber:
    raise newRuntimeError(operator, "Operands must be numbers.")

method evaluate(expr: Expr): LiteralValue {.base.} =
  ## Base method that raises `CatchableError` exception when `expr` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method evaluate(expr: Literal): LiteralValue =
  ## Returns a `LiteralValue` from the evaluation of a `Literal` expression.
  expr.value

method evaluate(expr: Grouping): LiteralValue =
  ## Returns a `LiteralValue` from the evaluation of a `Grouping` expression.
  evaluate(expr.expression)

method evaluate(expr: Unary): LiteralValue =
  ## Returns a `LiteralValue` from the evaluation of an `Unary` expression.
  let right = evaluate(expr.right)

  case expr.operator.kind
  of Bang:
    result = initLiteralBoolean(not isTruthy(right))
  of Minus:
    checkNumberOperand(expr.operator, right)

    result = initLiteralNumber(-right.numberLit)
  else:
    result = initLiteral()

method evaluate(expr: Binary): LiteralValue =
  ## Returns a `LiteralValue` from the evaluation of an `Binary` expression.
  let
    left = evaluate(expr.left)
    right = evaluate(expr.right)

  case expr.operator.kind
  of BangEqual:
    result = initLiteralBoolean(not isEqual(left, right))
  of EqualEqual:
    result = initLiteralBoolean(isEqual(left, right))
  of Greater:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralBoolean(left.numberLit > right.numberLit)
  of GreaterEqual:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralBoolean(left.numberLit >= right.numberLit)
  of Less:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralBoolean(left.numberLit < right.numberLit)
  of LessEqual:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralBoolean(left.numberLit <= right.numberLit)
  of Minus:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralNumber(left.numberLit - right.numberLit)
  of Plus:
    if left.kind == LitNumber and right.kind == LitNumber:
      result = initLiteralNumber(left.numberLit + right.numberLit)
    elif left.kind == LitString and right.kind == LitString:
      result = initLiteralString(left.stringLit & right.stringLit)
    else:
      raise newRuntimeError(expr.operator,
                            "Operands must be two numbers or two strings.")
  of Slash:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralNumber(left.numberLit / right.numberLit)
  of Star:
    checkNumberOperands(expr.operator, left, right)

    result = initLiteralNumber(left.numberLit * right.numberLit)
  else:
    result = initLiteral()

method evaluate(expr: Variable): LiteralValue =
  ## Returns a `LiteralValue` from the evaluation of a `Variable` expression.
  get(environment.environment, expr.name)

method evaluate(expr: Assign): LiteralValue =
  ## Returns a `LiteralValue` from the evaluation of an `Assign` expression.
  result = evaluate(expr.value)

  assign(environment.environment, expr.name, result)

method evaluate(expr: Logical): LiteralValue =
  result = evaluate(expr.left)

  block shortCircuit:
    if expr.operator.kind == Or:
      if isTruthy(result):
        break shortCircuit
    elif not isTruthy(result):
      break shortCircuit

    result = evaluate(expr.right)

proc stringify(literal: LiteralValue): string =
  ## Returns a `string` of `literal`. This is different from the `$` operator
  ## for the `LiteralValue` type.
  case literal.kind
  of LitNull:
    result = "nil"
  of LitNumber:
    result = $literal.numberLit

    if endsWith(result, ".0"):
      setLen(result, len(result) - 2)
  of LitString:
    result = literal.stringLit
  of LitBoolean:
    result = $literal.booleanLit

proc executeBlock(statements: seq[Stmt], env: Environment) =
  ## Runs `statements` from a higher block and changes the global environment
  ## variable reference to `env`.
  let previous = environment.environment

  try:
    environment.environment = env

    for statement in statements:
      execute(statement)
  finally:
    environment.environment = previous

method evaluate(stmt: Stmt) {.base.} =
  ## Base method that raises `CatchableError` exception when `stmt` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method evaluate(stmt: Expression) =
  ## Evaluate the `Expression` statement.
  discard evaluate(stmt.expression)

method evaluate(stmt: Print) =
  ## Evaluate the `Print` statement.
  let value = evaluate(stmt.expression)

  echo stringify(value)

method evaluate(stmt: Var) =
  ## Evaluate the `Var` statement.
  var value = initLiteral()

  if not isNil(stmt.initializer):
    value = evaluate(stmt.initializer)

  define(environment.environment, stmt.name.lexeme, value)

method evaluate(stmt: Block) =
  ## Evaluate the `Block` statement.
  executeBlock(stmt.statements, newEnvironment(environment.environment))

method evaluate(stmt: If) =
  if isTruthy(evaluate(stmt.condition)):
    execute(stmt.thenBranch)
  elif not isNil(stmt.elseBranch):
    execute(stmt.elseBranch)

proc execute(stmt: Stmt) =
  ## Helper procedure to evaluate `stmt`.
  evaluate(stmt)

proc interpret*(statements: seq[Stmt]) =
  ## Try to execute `statements`. Otherwise, it throws a runtime error.
  try:
    for statement in statements:
      execute(statement)
  except RuntimeError as error:
    runtimeError(error)

when defined(nloxTests):
  proc interpretForEvaluateTest*(expression: Expr): string =
    ## Attempts to evaluate `expression` and returns the stringified value.
    ## Otherwise, it throws a runtime error.
    try:
      let value = evaluate(expression)

      result = stringify(value)
    except RuntimeError as error:
      runtimeError(error)
