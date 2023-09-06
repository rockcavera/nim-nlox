# Stdlib imports
import std/[math, strformat, strutils, times]

# Internal imports
import ./environment, ./expr, ./literals, ./logger, ./runtimeerror, ./stmt,
       ./types

import "./return"

# Forward declaration
proc execute(interpreter: var Interpreter, stmt: Stmt)

proc defineClock(interpreter: var Interpreter) =
  var clock = new(LoxCallable)

  proc arity(caller: LoxCallable): int = 0

  proc call(caller: LoxCallable, interpreter: var Interpreter,
            arguments: seq[Object]): Object =
    let
      currentTime = getTime()
      seconds = float(toUnix(currentTime))
      milliseconds = float(convert(Nanoseconds, Milliseconds,
                                   nanosecond(currentTime))) / 1000.0

    result = newNumber(seconds + milliseconds)

  proc toString(caller: LoxCallable): string = "<native fn>"

  clock.arity = arity
  clock.call = call
  clock.toString = toString

  define(interpreter.globals, "clock", clock)

proc initInterpreter*(): Interpreter =
  ## Initializes an `Interpreter` object.
  result.globals = newEnvironment()
  result.environment = result.globals

  defineClock(result)

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
  elif a of Number:
    if b of Number:
      if isNaN(Number(a).data) and isNaN(Number(b).data):
        result = true
      else:
        result = Number(a).data == Number(b).data
  elif a of Boolean:
    if b of Boolean:
      result = Boolean(a).data == Boolean(b).data
  elif a of String:
    if b of String:
      result = String(a).data == String(b).data

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

method evaluate(expr: Expr, interpreter: var Interpreter): Object {.base.} =
  ## Base method that raises `CatchableError` exception when `expr` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method evaluate(expr: Literal, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `Literal` expression.
  expr.value

method evaluate(expr: Grouping, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `Grouping` expression.
  evaluate(expr.expression, interpreter)

method evaluate(expr: Unary, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of an `Unary` expression.
  let right = evaluate(expr.right, interpreter)

  case expr.operator.kind
  of Bang:
    result = newBoolean(not isTruthy(right))
  of Minus:
    checkNumberOperand(expr.operator, right)

    result = newNumber(-Number(right).data)
  else:
    result = newObject()

method evaluate(expr: Binary, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of an `Binary` expression.
  let
    left = evaluate(expr.left, interpreter)
    right = evaluate(expr.right, interpreter)

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

method evaluate(expr: Variable, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `Variable` expression.
  get(interpreter.environment, expr.name)

method evaluate(expr: Assign, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of an `Assign` expression.
  result = evaluate(expr.value, interpreter)

  assign(interpreter.environment, expr.name, result)

method evaluate(expr: Logical, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `Logical` expression.
  result = evaluate(expr.left, interpreter)

  block shortCircuit:
    if expr.operator.kind == Or:
      if isTruthy(result):
        break shortCircuit
    elif not isTruthy(result):
      break shortCircuit

    result = evaluate(expr.right, interpreter)

proc executeBlock*(interpreter: var Interpreter, statements: seq[Stmt],
                   environment: Environment) =
  ## Runs `statements` from a higher block and changes the global environment
  ## variable reference to `environment`.
  let previous = interpreter.environment

  try:
    interpreter.environment = environment

    for statement in statements:
      execute(interpreter, statement)
  finally:
    interpreter.environment = previous

# Delayed imports
import ./loxfunction

proc stringify(literal: Object): string =
  ## Returns a `string` of `literal`. This is different from the `$` operator
  ## for the `Object` type.
  if isNil(literal):
    result = "nil"
  elif literal of LoxFunction:
    let function = cast[LoxFunction](literal)

    result = toString(function)
  elif literal of LoxCallable:
    let function = cast[LoxCallable](literal)

    result = function.toString(function)
  else:
    result = $literal

    if literal of Number:
      if endsWith(result, ".0"):
        setLen(result, len(result) - 2)

method evaluate(stmt: Stmt, interpreter: var Interpreter) {.base.} =
  ## Base method that raises `CatchableError` exception when `stmt` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method evaluate(stmt: Expression, interpreter: var Interpreter) =
  ## Evaluate the `Expression` statement.
  discard evaluate(stmt.expression, interpreter)

method evaluate(stmt: Print, interpreter: var Interpreter) =
  ## Evaluate the `Print` statement.
  let value = evaluate(stmt.expression, interpreter)

  echo stringify(value)

method evaluate(stmt: Var, interpreter: var Interpreter) =
  ## Evaluate the `Var` statement.
  var value = newObject()

  if not isNil(stmt.initializer):
    value = evaluate(stmt.initializer, interpreter)

  define(interpreter.environment, stmt.name.lexeme, value)

method evaluate(stmt: Block, interpreter: var Interpreter) =
  ## Evaluate the `Block` statement.
  executeBlock(interpreter, stmt.statements,
               newEnvironment(interpreter.environment))

method evaluate(stmt: If, interpreter: var Interpreter) =
  ## Evaluate the `If` statement.
  if isTruthy(evaluate(stmt.condition, interpreter)):
    execute(interpreter, stmt.thenBranch)
  elif not isNil(stmt.elseBranch):
    execute(interpreter, stmt.elseBranch)

method evaluate(stmt: While, interpreter: var Interpreter) =
  ## Evaluate the `While` statement.
  while isTruthy(evaluate(stmt.condition, interpreter)):
    execute(interpreter, stmt.body)

method evaluate(stmt: stmt.Return, interpreter: var Interpreter) =
  var value: Object = nil

  if not isNil(stmt.value):
    value = evaluate(stmt.value, interpreter)

  raise newReturn(value)

method evaluate(stmt: Function, interpreter: var Interpreter) =
  let function = newLoxFunction(stmt)

  define(interpreter.environment, stmt.name.lexeme, function)

method evaluate(expr: Call, interpreter: var Interpreter): Object =
  let callee = evaluate(expr.callee, interpreter)

  var arguments = newSeqOfCap[Object](len(expr.arguments))

  for argument in expr.arguments:
    add(arguments, evaluate(argument, interpreter))

  if callee of LoxFunction:
    let function = cast[LoxFunction](callee)

    if len(arguments) != arity(function):
      raise newRuntimeError(expr.paren,
                            fmt"Expected {arity(function)} arguments but got " &
                            fmt"{len(arguments)}.")

    result = call(function, interpreter, arguments)
  elif callee of LoxCallable:
    let function = cast[LoxCallable](callee)

    if len(arguments) != function.arity(function):
      raise newRuntimeError(expr.paren,
                            fmt"Expected {function.arity(function)} arguments" &
                            fmt" but got {len(arguments)}.")

    result = function.call(function, interpreter, arguments)
  else:
    raise newRuntimeError(expr.paren, "Can only call functions and classes.")

proc execute(interpreter: var Interpreter, stmt: Stmt) =
  ## Helper procedure to evaluate `stmt`.
  evaluate(stmt, interpreter)

proc interpret*(lox: var Lox, statements: seq[Stmt]) =
  ## Try to execute `statements`. Otherwise, it throws a runtime error.
  try:
    for statement in statements:
      execute(lox.interpreter, statement)
  except RuntimeError as error:
    runtimeError(lox, error)

when defined(nloxTests):
  proc interpretForEvaluateTest*(lox: var Lox, expression: Expr): string =
    ## Attempts to evaluate `expression` and returns the stringified value.
    ## Otherwise, it throws a runtime error.
    try:
      let value = evaluate(expression, lox.interpreter)

      result = stringify(value)
    except RuntimeError as error:
      runtimeError(lox, error)
