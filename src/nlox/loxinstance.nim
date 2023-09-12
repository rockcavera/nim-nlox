import std/[strformat, tables]

import ./runtimeerror, ./types

proc toString*(instance: LoxInstance): string =
  result = fmt"{instance.klass.name} instance"

proc set*(instance: LoxInstance, name: Token, value: Object) =
  instance.fields[name.lexeme] = value

# Delayed imports
import ./loxclass, ./loxfunction # loxclass import `newLoxInstance()`

proc get*(instance: LoxInstance, name: Token): Object =
  if hasKey(instance.fields, name.lexeme):
    result = instance.fields[name.lexeme]
  else:
    let `method` = instance.klass.findMethod(name.lexeme)

    if isNil(`method`):
      raise newRuntimeError(name, fmt"Undefined property '{name.lexeme}'.")
    else:
      result = `bind`(`method`, instance)
