import std/tables

import ./initializers, ./types

proc toString*(class: LoxClass): string = class.name

proc arity*(class: LoxClass): int = 0

proc findMethod*(class: LoxClass, name: string): LoxFunction =
  getOrDefault(class.methods, name, nil)

proc call*(class: LoxClass, interpreter: var Interpreter,
           arguments: seq[Object]): Object =
  newLoxInstance(class)
