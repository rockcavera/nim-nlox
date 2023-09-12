import std/[strformat, tables]

import ./runtimeerror, ./types

proc newLoxInstance*(klass: LoxClass): LoxInstance =
  result = new(LoxInstance)
  result.klass = klass

proc toString*(instance: LoxInstance): string =
  result = fmt"{instance.klass.name} instance"

proc get*(instance: LoxInstance, name: Token): Object =
  if hasKey(instance.fields, name.lexeme):
    result = instance.fields[name.lexeme]
  else:
    raise newRuntimeError(name, fmt"Undefined property '{name.lexeme}'.")

proc set*(instance: LoxInstance, name: Token, value: Object) =
  instance.fields[name.lexeme] = value
