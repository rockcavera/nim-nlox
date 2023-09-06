# Stdlib imports
import std/strformat

# Internal imports
import ./environment, ./interpreter, ./stmt, ./types

type
  LoxFunction* = ref object of LoxCallable
    ## Object that stores Lox function information.
    declaration: Function
      ## Lox function declarations.
    closure: Environment
      ## Stores the function's current environment.

proc call*(caller: LoxFunction, interpreter: var Interpreter,
          arguments: seq[Object]): Object =
  ## Evaluates a `caller` and returns `Object`.
  var environment = newEnvironment(caller.closure)

  for i in 0 ..< len(caller.declaration.params):
    define(environment, caller.declaration.params[i].lexeme, arguments[i])

  result = nil

  try:
    executeBlock(interpreter, caller.declaration.body, environment)
  except types.Return as returnValue:
    result = returnValue.value

proc arity*(caller: LoxFunction): int =
  ## Returns the arity of `caller`
  len(caller.declaration.params)

proc toString*(caller: LoxFunction): string =
  ## Returns a representation of `caller` in `string`.
  fmt"<fn {caller.declaration.name.lexeme}>"

proc newLoxFunction*(declaration: Function, closure: Environment): LoxFunction =
  ## Create a `LoxFunction` with `declaration` and the current environment
  ## `closure`.
  result = new(LoxFunction)
  result.declaration = declaration
  result.closure = closure
