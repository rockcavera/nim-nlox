import std/strformat

import ./environment, ./interpreter, ./stmt, ./types

type
  LoxFunction* = ref object of LoxCallable
    declaration: Function

proc call*(caller: LoxFunction, interpreter: var Interpreter,
          arguments: seq[Object]): Object =
  var environment = newEnvironment(interpreter.globals)

  for i in 0 ..< len(caller.declaration.params):
    define(environment, caller.declaration.params[i].lexeme, arguments[i])

  result = nil

  try:
    executeBlock(interpreter, caller.declaration.body, environment)
  except types.Return as returnValue:
    result = returnValue.value

proc arity*(caller: LoxFunction): int =
  len(caller.declaration.params)

proc toString*(caller: LoxFunction): string =
  fmt"<fn {caller.declaration.name.lexeme}>"

proc newLoxFunction*(declaration: Function): LoxFunction =
  result = new(LoxFunction)
  result.declaration = declaration
