import std/[tables, strformat]

import ./literals, ./runtimeerror, ./token

type
  Environment* = object
    values: Table[string, LiteralValue]

proc initEnvironment*(): Environment =
  Environment(values: initTable[string, LiteralValue]())

proc define*(environment: var Environment, name: string, value: LiteralValue) =
  environment.values[name] = value

proc get*(environment: var Environment, name: Token): LiteralValue =
  if hasKey(environment.values, name.lexeme):
    result = environment.values[name.lexeme]
  else:
    raise newRuntimeError(name, fmt"Undefined variable '{name.lexeme}'.")

var environment* = initEnvironment()
