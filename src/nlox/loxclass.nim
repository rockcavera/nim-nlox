import std/tables

import ./loxinstance, ./types

proc newLoxClass*(name: string, methods: Table[string, LoxFunction]): LoxClass =
  result = new(LoxClass)
  result.name = name
  result.methods = methods

proc toString*(class: LoxClass): string = class.name

proc call*(class: LoxClass, interpreter: var Interpreter,
           arguments: seq[Object]): Object =
  newLoxInstance(class)

proc arity*(class: LoxClass): int = 0

proc findMethod*(class: LoxClass, name: string): LoxFunction =
  getOrDefault(class.methods, name, nil)
