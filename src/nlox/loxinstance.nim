# Stdlib imports
import std/[strformat, tables]

# Internal imports
import ./runtimeerror, ./types

proc toString*(instance: LoxInstance): string =
  ## Returns a representation of `instance` in `string`.
  result = fmt"{instance.klass.name} instance"

proc set*(instance: LoxInstance, name: Token, value: Object) =
  ## Defines `name` as `value` in `instance`.
  instance.fields[name.lexeme] = value

# Delayed imports
import ./loxclass, ./loxfunction

proc get*(instance: LoxInstance, name: Token): Object =
  ## Returns the `Object` bound to `name` in `instance`.
  if hasKey(instance.fields, name.lexeme):
    result = instance.fields[name.lexeme]
  else:
    let `method` = instance.klass.findMethod(name.lexeme)

    if isNil(`method`):
      raise newRuntimeError(name, fmt"Undefined property '{name.lexeme}'.")
    else:
      result = `bind`(`method`, instance)
