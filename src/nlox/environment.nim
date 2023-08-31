import std/[tables, strformat]

import ./literals, ./runtimeerror, ./token

type
  Environment* = object
    values: Table[string, LiteralValue]

proc define*(env: var Environment, name: string, value: LiteralValue) =
  env.values[name] = value

proc get*(env: var Environment, name: Token): LiteralValue =
  if hasKey(env.values, name.lexeme):
    result = env.values[name.lexeme]
  else:
    raise newRuntimeError(name, fmt"Undefined variable '{name.lexeme}'.")
