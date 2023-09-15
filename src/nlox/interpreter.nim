# Stdlib imports
import std/[math, strformat, strutils, tables]

# Internal imports
import ./environment, ./hashes2, ./initializers, ./literals, ./logger,
       ./nativefunctions, ./runtimeerror, ./types

# Internal import of module with keyword name
import "./return"

# Forward declaration
proc execute(interpreter: var Interpreter, stmt: Stmt)

proc initInterpreter*(): Interpreter =
  ## Initializes an `Interpreter` object.
  result.globals = newEnvironment()
  result.environment = result.globals

  defineAllNativeFunctions(result)

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
  elif a of LoxClass:
    if b of LoxClass:
      result = a == b
  elif a of LoxFunction:
    if b of LoxFunction:
      result = a == b
  elif a of LoxInstance:
    if b of LoxInstance:
      result = a == b
  elif a of LoxCallable:
    if b of LoxCallable:
      result = a == b

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

proc lookUpVariable(interpreter: var Interpreter, name: Token, expr: Expr):
                   Object =
  ## Returns an `Object` from the search for a variable with the name `name`.
  let distance = getOrDefault(interpreter.locals, expr, -1)

  if distance == -1:
    result = get(interpreter.globals, name)
  else:
    result = getAt(interpreter.environment, distance, name.lexeme)

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
import ./loxfunction # The `loxfunction` module calls `executeBlock()`

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
  lookUpVariable(interpreter, expr.name, expr)

method evaluate(expr: Assign, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of an `Assign` expression.
  result = evaluate(expr.value, interpreter)

  let distance = getOrDefault(interpreter.locals, expr, -1)

  if distance == -1:
    assign(interpreter.globals, expr.name, result)
  else:
    assignAt(interpreter.environment, distance, expr.name, result)

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

# Delayed imports
import ./loxclass

method evaluate(expr: Call, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `Call` expression.
  let callee = evaluate(expr.callee, interpreter)

  var arguments = newSeqOfCap[Object](len(expr.arguments))

  for argument in expr.arguments:
    add(arguments, evaluate(argument, interpreter))

  # use method?
  if callee of LoxClass:
    let class = cast[LoxClass](callee)

    if len(arguments) != arity(class):
      raise newRuntimeError(expr.paren,
                            fmt"Expected {arity(class)} arguments but got " &
                            fmt"{len(arguments)}.")

    result = call(class, interpreter, arguments)
  elif callee of LoxFunction:
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

method evaluate(expr: Super, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `Super` expression.
  let
    distance = interpreter.locals[expr]
    superclass = cast[LoxClass](getAt(interpreter.environment, distance,
                                      "super"))
    obj = cast[LoxInstance](getAt(interpreter.environment, distance - 1,
                                  "this"))
    `method` = findMethod(superclass, expr.`method`.lexeme)

  if isNil(`method`):
    raise newRuntimeError(expr.`method`,
                          fmt"Undefined property '{expr.`method`.lexeme}'.")

  result = `bind`(`method`, obj)

method evaluate(expr: This, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `This` expression.
  lookUpVariable(interpreter, expr.keyword, expr)

# Delayed imports
import ./loxinstance

method evaluate(expr: Get, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `Get` expression.
  let obj = evaluate(expr.obj, interpreter)

  if obj of LoxInstance:
    result = get(cast[LoxInstance](obj), expr.name)
  else:
    raise newRuntimeError(expr.name, "Only instances have properties.")

method evaluate(expr: Set, interpreter: var Interpreter): Object =
  ## Returns a `Object` from the evaluation of a `Set` expression.
  let obj = evaluate(expr.obj, interpreter)

  if obj of LoxInstance:
    result = evaluate(expr.value, interpreter)

    set(cast[LoxInstance](obj), expr.name, result)
  else:
    raise newRuntimeError(expr.name, "Only instances have fields.")

proc stringify(literal: Object): string =
  ## Returns a `string` of `literal`. This is different from the `$` operator
  ## for the `Object` type.
  if isNil(literal):
    result = "nil"
  elif literal of LoxClass:
    let class = cast[LoxClass](literal)

    result = toString(class)
  elif literal of LoxFunction:
    let function = cast[LoxFunction](literal)

    result = toString(function)
  elif literal of LoxCallable:
    let function = cast[LoxCallable](literal)

    result = function.toString(function)
  elif literal of LoxInstance:
    let instance = cast[LoxInstance](literal)

    result = toString(instance)
  else:
    result = $literal

    if literal of Number:
      if endsWith(result, ".0"):
        setLen(result, len(result) - 2)
      elif result == "nan":
        result = "NaN"

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

method evaluate(stmt: types.Return, interpreter: var Interpreter) =
  ## Evaluate the `Return` statement.
  var value: Object = nil

  if not isNil(stmt.value):
    value = evaluate(stmt.value, interpreter)

  raise newReturn(value)

method evaluate(stmt: Function, interpreter: var Interpreter) =
  ## Evaluate the `Function` statement.
  let function = newLoxFunction(stmt, interpreter.environment, false)

  define(interpreter.environment, stmt.name.lexeme, function)

method evaluate(stmt: Class, interpreter: var Interpreter) =
  ## Evaluate the `Class` statement.
  var superclass: Object = nil

  if not isNil(stmt.superclass):
    superclass = evaluate(stmt.superclass, interpreter)

    if not(superclass of LoxClass):
      raise newRuntimeError(stmt.superclass.name,"Superclass must be a class.")

  define(interpreter.environment, stmt.name.lexeme, nil)

  if not isNil(stmt.superclass):
    interpreter.environment = newEnvironment(interpreter.environment, 1)

    define(interpreter.environment, "super", superclass)

  var methods = initTable[string, LoxFunction]()

  for `method` in stmt.methods:
    let function = newLoxFunction(`method`, interpreter.environment,
                                  `method`.name.lexeme == "init")

    methods[`method`.name.lexeme] = function

  let klass = newLoxClass(stmt.name.lexeme, cast[LoxClass](superclass), methods)

  if not isNil(stmt.superclass):
    interpreter.environment = interpreter.environment.enclosing

  assign(interpreter.environment, stmt.name, klass)

proc execute(interpreter: var Interpreter, stmt: Stmt) =
  ## Helper procedure to evaluate `stmt`.
  evaluate(stmt, interpreter)

proc resolve*(lox: var Lox, expr: Expr, depth: int) =
  ## Defines in `lox.interpreter.locals` the `depth` amount of scopes between
  ## the current scope and where the `expr` variable is defined.
  lox.interpreter.locals[expr] = depth

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
