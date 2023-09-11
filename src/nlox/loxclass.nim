import ./loxinstance, ./types

proc newLoxClass*(name: string): LoxClass =
  result = new(LoxClass)
  result.name = name

proc toString*(class: LoxClass): string = class.name

proc call*(class: LoxClass, interpreter: var Interpreter,
           arguments: seq[Object]): Object =
  newLoxInstance(class)

proc arity*(class: LoxClass): int = 0
