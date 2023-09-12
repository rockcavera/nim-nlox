# Stdlib imports
import std/strformat

# Internal imports
import ./environment, ./initializers, ./stmt, ./types

proc arity*(caller: LoxFunction): int =
  ## Returns the arity of `caller`
  len(caller.declaration.params)

proc toString*(caller: LoxFunction): string =
  ## Returns a representation of `caller` in `string`.
  fmt"<fn {caller.declaration.name.lexeme}>"

proc `bind`*(caller: LoxFunction, instance: LoxInstance): LoxFunction =
  let environment = newEnvironment(caller.closure)

  define(environment, "this", instance)

  result = newLoxFunction(caller.declaration, environment)

import ./interpreter

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
