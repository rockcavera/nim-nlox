# Stdlib imports
import std/[strformat, tables]

# Internal imports
import ./hashes3, ./runtimeerror, ./types

proc newLoxInstance*(klass: LoxClass): LoxInstance =
  ## Creates and returns a `LoxInstance` with `klass`.
  LoxInstance(klass: klass, fields: nil)

proc set*(instance: LoxInstance, name: Token, value: Object) =
  ## Defines `name` as `value` in `instance`.
  if isNil(instance.fields):
    instance.fields = newTable[String, Object](4)

  instance.fields[name.lexeme] = value

# Delayed imports
import ./loxclass, ./loxfunction

proc get*(instance: LoxInstance, name: Token): Object =
  ## Returns the `Object` bound to `name` in `instance`.
  if not(isNil(instance.fields)) and hasKey(instance.fields, name.lexeme):
    result = instance.fields[name.lexeme]
  else:
    let `method` = findMethod(instance.klass, name.lexeme)

    if isNil(`method`):
      raise newRuntimeError(name, fmt"Undefined property '{name.lexeme.data}'.")
    else:
      result = `bind`(`method`, instance)
