# Stdlib imports
import std/[hashes, tables, strformat]

# Internal imports
import ./hashes3, ./runtimeerror, ./types

proc newEnvironment*(): Environment =
  ## Creates a new `Environment` with `enclosing` equal to `nil`.
  Environment(enclosing: nil, values: newTable[String, Object](16))

proc newEnvironment*(enclosing: Environment): Environment =
  ## Creates a new `Environment` and sets the outer environment to `enclosing`.
  Environment(enclosing: enclosing, values: nil)

proc newEnvironment*(enclosing: Environment, size: int): Environment =
  ## Creates a new `Environment` and sets the outer environment to `enclosing`.
  Environment(enclosing: enclosing, values: newTable[String, Object](size))

proc define*(environment: Environment, name: String, value: Object) =
  ## Defines in the environment `environment` the variable `name` with the value
  ## `value`.
  if isNil(environment.values):
    environment.values = newTable[String, Object](2)

  environment.values[name] = value

proc ancestor*(environment: Environment, distance: int): Environment =
  ## Returns the environment that is a `distance` from the current environment.
  result = environment

  for i in 1 .. distance:
    result = result.enclosing

proc getAt*(environment: Environment, distance: int, name: String): Object =
  ## Returns the `Object` of `name`, which is in an environment at a `distance`
  ## from the current environment.
  ancestor(environment, distance).values[name]

proc assignAt*(environment: Environment, distance: int, name: Token,
               value: Object) =
  ## Assigns `value` to `name`, which is in an environment a `distance` from the
  ## current environment.
  ancestor(environment, distance).values[name.lexeme] = value

proc get*(environment: Environment, name: Token): Object =
  ## Returns the `Object` value of the `name` variable of the
  ## `environment` environment. If the `name` variable is not defined in the
  ## current environment level, it will look in the outermost environments. If
  ## not found, it raises a `RuntimeError`.
  if not(isNil(environment.values)) and hasKey(environment.values, name.lexeme):
    result = environment.values[name.lexeme]
  elif not isNil(environment.enclosing):
    result = get(environment.enclosing, name)
  else:
    raise newRuntimeError(name, fmt"Undefined variable '{name.lexeme.data}'.")

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
    raise newRuntimeError(name, fmt"Undefined variable '{name.lexeme.data}'.")
