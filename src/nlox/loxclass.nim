# Stdlib imports
import std/tables

# Internal imports
import ./initializers, ./types

proc toString*(class: LoxClass): string = class.name
  ## Returns a representation of `class` in `string`.

proc findMethod*(class: LoxClass, name: string): LoxFunction =
  ## Returns a `LoxFunction` referring to the name `name` within the `LoxClass`
  ## `class`. If not found, returns `nil`.
  getOrDefault(class.methods, name, nil)

# Delayed imports
import ./loxfunction

proc arity*(class: LoxClass): int =
  ## Returns the arity of `class`
  let initializer = findMethod(class, "init")

  if isNil(initializer):
    result = 0
  else:
    result = loxfunction.arity(initializer)

proc call*(class: LoxClass, interpreter: var Interpreter,
           arguments: seq[Object]): Object =
  ## Returns a `LoxInstance` of `class` and evaluates the `init` method, if
  ## present in `class.`
  result = newLoxInstance(class)

  let initializer = findMethod(class, "init")

  if not isNil(initializer):
    discard loxfunction.call(`bind`(initializer, cast[LoxInstance](result)),
                             interpreter, arguments)
