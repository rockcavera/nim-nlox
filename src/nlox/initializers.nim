import std/tables

import ./stmt, ./types

proc newLoxClass*(name: string, methods: Table[string, LoxFunction]): LoxClass =
  result = new(LoxClass)
  result.name = name
  result.methods = methods

proc newLoxInstance*(klass: LoxClass): LoxInstance =
  result = new(LoxInstance)
  result.klass = klass

proc newLoxFunction*(declaration: Function, closure: Environment,
                     isInitializer: bool): LoxFunction =
  ## Create a `LoxFunction` with `declaration` and the current environment
  ## `closure`.
  result = new(LoxFunction)
  result.declaration = declaration
  result.closure = closure
  result.isInitializer = isInitializer
