import std/[tables, strformat]

import ./literals, ./runtimeerror, ./token

type
  Environment* = ref object
    enclosing: Environment
    values: Table[string, LiteralValue]

proc newEnvironment*(): Environment =
  Environment(enclosing: nil, values: initTable[string, LiteralValue]())

proc newEnvironment*(enclosing: Environment): Environment =
  Environment(enclosing: enclosing, values: initTable[string, LiteralValue]())

proc define*(environment: Environment, name: string, value: LiteralValue) =
  environment.values[name] = value

proc get*(environment: Environment, name: Token): LiteralValue =
  if hasKey(environment.values, name.lexeme):
    result = environment.values[name.lexeme]
  elif not isNil(environment.enclosing):
    result = get(environment.enclosing, name)
  else:
    raise newRuntimeError(name, fmt"Undefined variable '{name.lexeme}'.")

proc assign*(environment: Environment, name: Token, value: LiteralValue) =
  if hasKey(environment.values, name.lexeme):
    environment.values[name.lexeme] = value
  elif not isNil(environment.enclosing):
    assign(environment.enclosing, name, value)
  else:
    raise newRuntimeError(name, fmt"Undefined variable '{name.lexeme}'.")

var environment* = newEnvironment()
