# Stdlib imports
import std/[tables, strformat]

# Internal imports
import ./runtimeerror, ./types

proc newEnvironment*(): Environment =
  ## Creates a new `Environment` with `enclosing` equal to `nil`.
  Environment(enclosing: nil, values: initTable[string, Object]())

proc newEnvironment*(enclosing: Environment): Environment =
  ## Creates a new `Environment` and sets the outer environment to `enclosing`.
  Environment(enclosing: enclosing, values: initTable[string, Object]())

proc define*(environment: Environment, name: string, value: Object) =
  ## Defines in the environment `environment` the variable `name` with the value
  ## `value`.
  environment.values[name] = value

proc get*(environment: Environment, name: Token): Object =
  ## Returns the `Object` value of the `name` variable of the
  ## `environment` environment. If the `name` variable is not defined in the
  ## current environment level, it will look in the outermost environments. If
  ## not found, it raises a `RuntimeError`.
  if hasKey(environment.values, name.lexeme):
    result = environment.values[name.lexeme]
  elif not isNil(environment.enclosing):
    result = get(environment.enclosing, name)
  else:
    raise newRuntimeError(name, fmt"Undefined variable '{name.lexeme}'.")

proc assign*(environment: Environment, name: Token, value: Object) =
  ## Assigns to the `name` variable, from the `environment` environment, the
  ## value `value`. If the `name` variable is not defined in the current
  ## environment level, it will look in the outermost environments. If not
  ## found, it raises a `RuntimeError`.
  if hasKey(environment.values, name.lexeme):
    environment.values[name.lexeme] = value
  elif not isNil(environment.enclosing):
    assign(environment.enclosing, name, value)
  else:
    raise newRuntimeError(name, fmt"Undefined variable '{name.lexeme}'.")
