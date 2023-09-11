import ./types

type
  LoxClass* = ref object of Object
    name*: string

proc newLoxClass*(name: string): LoxClass =
  result = new(LoxClass)
  result.name = name
