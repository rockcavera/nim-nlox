# Stdlib imports
import std/[math, strutils]

# Internal imports
import ./environment, ./expr, ./literals, ./logger, ./runtimeerror, ./stmt,
       ./types

# Forward declaration
proc execute(stmt: Stmt)

proc isTruthy(literal: Object): bool =
  ## Transforms the `literal` object into a boolean type and returns it.
  if isNil(literal):
    result = false
  elif literal of Boolean:
    result = Boolean(literal).data
  else:
    result = true

proc isEqual(a: Object, b: Object): bool =
  ## Returns `true` if objects `a` and `b` are equal. Otherwise, it returns
  ## `false`.
  if isNil(a):
    if isNil(b):
      result = true
    else:
      result = false
  elif a of Number:
    if b of Number:
      if isNaN(Number(a).data) and isNaN(Number(b).data):
        result = true
      else:
        result = Number(a).data == Number(b).data
    else:
      result = false
  elif a of Boolean:
    if b of Boolean:
      result = Boolean(a).data == Boolean(b).data
    else:
      result = false
  elif a of String:
    if b of String:
      result = String(a).data == String(b).data
    else:
      result = false

proc checkNumberOperand(operator: Token, operand: Object) =
  ## Checks if `operand` is a number, and if it is, it does nothing. Otherwise,
  ## it raises a `RuntimeError`.
  if not(operand of Number):
    raise newRuntimeError(operator, "Operand must be a number.")

proc checkNumberOperands(operator: Token, left: Object, right: Object) =
  ## Checks if the operands `left` and `right` are numbers, and if they are, it
  ## does nothing. Otherwise, it raises a `RuntimeError`.
  if not(left of Number) or not(right of Number):
    raise newRuntimeError(operator, "Operands must be numbers.")

method evaluate(expr: Expr): Object {.base.} =
  ## Base method that raises `CatchableError` exception when `expr` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method evaluate(expr: Literal): Object =
  ## Returns a `Object` from the evaluation of a `Literal` expression.
  expr.value

method evaluate(expr: Grouping): Object =
  ## Returns a `Object` from the evaluation of a `Grouping` expression.
  evaluate(expr.expression)

method evaluate(expr: Unary): Object =
  ## Returns a `Object` from the evaluation of an `Unary` expression.
  let right = evaluate(expr.right)

  case expr.operator.kind
  of Bang:
    result = newBoolean(not isTruthy(right))
  of Minus:
    checkNumberOperand(expr.operator, right)

    result = newNumber(-Number(right).data)
  else:
    result = newObject()

method evaluate(expr: Binary): Object =
  ## Returns a `Object` from the evaluation of an `Binary` expression.
  let
    left = evaluate(expr.left)
    right = evaluate(expr.right)

  case expr.operator.kind
  of BangEqual:
    result = newBoolean(not isEqual(left, right))
  of EqualEqual:
    result = newBoolean(isEqual(left, right))
  of Greater:
    checkNumberOperands(expr.operator, left, right)

    result = newBoolean(Number(left).data > Number(right).data)
  of GreaterEqual:
    checkNumberOperands(expr.operator, left, right)

    result = newBoolean(Number(left).data >= Number(right).data)
  of Less:
    checkNumberOperands(expr.operator, left, right)

    result = newBoolean(Number(left).data < Number(right).data)
  of LessEqual:
    checkNumberOperands(expr.operator, left, right)

    result = newBoolean(Number(left).data <= Number(right).data)
  of Minus:
    checkNumberOperands(expr.operator, left, right)

    result = newNumber(Number(left).data - Number(right).data)
  of Plus:
    if left of Number and right of Number:
      result = newNumber(Number(left).data + Number(right).data)
    elif left of String and right of String:
      result = newString(String(left).data & String(right).data)
    else:
      raise newRuntimeError(expr.operator,
                            "Operands must be two numbers or two strings.")
  of Slash:
    checkNumberOperands(expr.operator, left, right)

    result = newNumber(Number(left).data / Number(right).data)
  of Star:
    checkNumberOperands(expr.operator, left, right)

    result = newNumber(Number(left).data * Number(right).data)
  else:
    result = newObject()

method evaluate(expr: Variable): Object =
  ## Returns a `Object` from the evaluation of a `Variable` expression.
  get(environment.environment, expr.name)

method evaluate(expr: Assign): Object =
  ## Returns a `Object` from the evaluation of an `Assign` expression.
  result = evaluate(expr.value)

  assign(environment.environment, expr.name, result)

method evaluate(expr: Logical): Object =
  ## Returns a `Object` from the evaluation of a `Logical` expression.
  result = evaluate(expr.left)

  block shortCircuit:
    if expr.operator.kind == Or:
      if isTruthy(result):
        break shortCircuit
    elif not isTruthy(result):
      break shortCircuit

    result = evaluate(expr.right)

proc stringify(literal: Object): string =
  ## Returns a `string` of `literal`. This is different from the `$` operator
  ## for the `Object` type.
  if isNil(literal):
    result = "nil"
  else:
    result = $literal

    if literal of Number:
      if endsWith(result, ".0"):
        setLen(result, len(result) - 2)

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
  var value = newObject()

  if not isNil(stmt.initializer):
    value = evaluate(stmt.initializer)

  define(environment.environment, stmt.name.lexeme, value)

method evaluate(stmt: Block) =
  ## Evaluate the `Block` statement.
  executeBlock(stmt.statements, newEnvironment(environment.environment))

method evaluate(stmt: If) =
  ## Evaluate the `If` statement.
  if isTruthy(evaluate(stmt.condition)):
    execute(stmt.thenBranch)
  elif not isNil(stmt.elseBranch):
    execute(stmt.elseBranch)

method evaluate(stmt: While) =
  ## Evaluate the `While` statement.
  while isTruthy(evaluate(stmt.condition)):
    execute(stmt.body)

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
