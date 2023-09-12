import std/tables

import ./initializers, ./types

proc toString*(class: LoxClass): string = class.name

proc findMethod*(class: LoxClass, name: string): LoxFunction =
  getOrDefault(class.methods, name, nil)

import ./loxfunction

proc arity*(class: LoxClass): int =
  let initializer = findMethod(class, "init")

  if isNil(initializer):
    result = 0
  else:
    result = loxfunction.arity(initializer)

proc call*(class: LoxClass, interpreter: var Interpreter,
           arguments: seq[Object]): Object =
  result = newLoxInstance(class)

  let initializer = findMethod(class, "init")

  if not isNil(initializer):
    discard loxfunction.call(`bind`(initializer, cast[LoxInstance](result)),
                             interpreter, arguments)
