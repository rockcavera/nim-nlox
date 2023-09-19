# Stdlib imports
import std/strformat

# Internal imports
import ./environment, ./literals, ./types

# Internal import of module with keyword name
import "./return"

# Forward declaration
proc call(caller: LoxCallable, interpreter: var Interpreter,
          arguments: seq[Object], ): Object

proc arity(caller: LoxCallable): int =
  ## Returns the arity of `caller`
  len(cast[LoxFunction](caller).declaration.params)

proc toString(caller: LoxCallable): string =
  ## Returns a representation of `caller` in `string`.
  fmt"<fn {cast[LoxFunction](caller).declaration.name.lexeme.data}>"

proc newLoxFunction*(declaration: Function, closure: Environment,
                     isInitializer: bool): LoxFunction =
  ## Create a `LoxFunction` with `declaration` and the current environment
  ## `closure`. If the `isInitializer` parameter is `true`, it informs that the
  ## `LoxFunction` is an initializer.
  LoxFunction(arity: arity, call: call, toString: toString,
              declaration: declaration, closure: closure,
              isInitializer: isInitializer)

proc `bind`*(caller: LoxFunction, instance: LoxInstance): LoxFunction =
  ## Returns a `LoxFunction`, which is an initializer, with a new environment,
  ## in which "this" is declared as a variable bound to `instance`.
  let environment = newEnvironment(caller.closure, 1)

  define(environment, stringWithHashThis, instance)

  result = newLoxFunction(caller.declaration, environment, caller.isInitializer)

# Delayed imports
import ./interpreter

proc call(caller: LoxCallable, interpreter: var Interpreter,
          arguments: seq[Object], ): Object =
  ## Evaluates a `caller` and returns `Object`.
  let caller = cast[LoxFunction](caller)

  var environment = newEnvironment(caller.closure,
                                   len(caller.declaration.params))

  for i in 0 ..< len(caller.declaration.params):
    define(environment, caller.declaration.params[i].lexeme, arguments[i])

  result = nil

  try:
    executeBlock(interpreter, caller.declaration.body, environment)
  except `return`.Return as returnValue:
    result = returnValue.value

  if (caller.isInitializer):
    result = getAt(caller.closure, 0, stringWithHashThis)
