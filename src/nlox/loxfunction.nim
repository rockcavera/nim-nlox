# Stdlib imports
import std/strformat

# Internal imports
import ./environment, ./literals, ./types

# Internal import of module with keyword name
import "./return"

# Forward declaration
proc call(function: LoxCallable, interpreter: var Interpreter,
          arguments: seq[Object], ): Object

proc arity(function: LoxCallable): int =
  ## Returns the arity of `function`
  len(cast[LoxFunction](function).declaration.params)

proc toString(function: LoxCallable): string =
  ## Returns a representation of `function` in `string`.
  fmt"<fn {cast[LoxFunction](function).declaration.name.lexeme.data}>"

proc newLoxFunction*(declaration: Function, closure: Environment,
                     isInitializer: bool): LoxFunction =
  ## Create a `LoxFunction` with `declaration` and the current environment
  ## `closure`. If the `isInitializer` parameter is `true`, it informs that the
  ## `LoxFunction` is an initializer.
  LoxFunction(arity: arity, call: call, toString: toString,
              declaration: declaration, closure: closure,
              isInitializer: isInitializer)

proc `bind`*(function: LoxFunction, instance: LoxInstance): LoxFunction =
  ## Returns a `LoxFunction`, which is an initializer, with a new environment,
  ## in which "this" is declared as a variable bound to `instance`.
  let environment = newEnvironment(function.closure, 1)

  define(environment, newStringWithHash("this"), instance)

  result = newLoxFunction(function.declaration, environment,
                          function.isInitializer)

# Delayed imports
import ./interpreter

proc call(function: LoxCallable, interpreter: var Interpreter,
          arguments: seq[Object], ): Object =
  ## Evaluates a `function` and returns `Object`.
  let function = cast[LoxFunction](function)

  var environment = newEnvironment(function.closure,
                                   len(function.declaration.params))

  for i in 0 ..< len(function.declaration.params):
    define(environment, function.declaration.params[i].lexeme, arguments[i])

  result = nil

  try:
    executeBlock(interpreter, function.declaration.body, environment)
  except `return`.Return as returnValue:
    result = returnValue.value

  if (function.isInitializer):
    result = getAt(function.closure, 0, newStringWithHash("this"))
