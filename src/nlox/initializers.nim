# Stdlib imports
import std/tables

# Internal imports
import ./stmt, ./types

# From loxclass

proc newLoxClass*(name: string, methods: Table[string, LoxFunction]): LoxClass =
  ## Creates and returns a `LoxClass` with the name `name` and the methods
  ## `methods`.
  result = new(LoxClass)
  result.name = name
  result.methods = methods

# End loxclass

# From loxinstance

proc newLoxInstance*(klass: LoxClass): LoxInstance =
  ## Creates and returns a `LoxInstance` with `klass`.
  result = new(LoxInstance)
  result.klass = klass

# End loxinstance

# From loxfunction

proc newLoxFunction*(declaration: Function, closure: Environment,
                     isInitializer: bool): LoxFunction =
  ## Create a `LoxFunction` with `declaration` and the current environment
  ## `closure`. If the `isInitializer` parameter is `true`, it informs that the
  ## `LoxFunction` is an initializer.
  result = new(LoxFunction)
  result.declaration = declaration
  result.closure = closure
  result.isInitializer = isInitializer

# End loxfunction
