# Stdlib imports
import std/tables

# Internal imports
import ./types

# Forward declaration
proc call(class: LoxCallable, interpreter: var Interpreter,
          arguments: seq[Object]): Object

proc toString(class: LoxCallable): string = cast[LoxClass](class).name
  ## Returns a representation of `class` in `string`.

proc findMethod*(class: LoxClass, name: string): LoxFunction =
  ## Returns a `LoxFunction` referring to the name `name` within the `LoxClass`
  ## `class`. If not found, returns `nil`.
  result = nil

  if not isNil(class.methods):
    result = getOrDefault(class.methods, name, nil)

  if isNil(result) and not(isNil(class.superclass)):
    result = findMethod(class.superclass, name)

proc arity(class: LoxCallable): int =
  ## Returns the arity of `class`
  let initializer = findMethod(cast[LoxClass](class), "init")

  if isNil(initializer):
    result = 0
  else:
    result = initializer.arity(initializer)

proc newLoxClass*(name: string, superclass: LoxClass,
                  methods: TableRef[string, LoxFunction]): LoxClass =
  ## Creates and returns a `LoxClass` with the name `name` and the methods
  ## `methods`.
  result = new(LoxClass)
  result.name = name
  result.superclass = superclass
  result.methods = methods
  result.call = call
  result.arity = arity
  result.toString = toString

# Delayed imports
import ./loxfunction, ./loxinstance

proc call(class: LoxCallable, interpreter: var Interpreter,
          arguments: seq[Object]): Object =
  ## Returns a `LoxInstance` of `class` and evaluates the `init` method, if
  ## present in `class.`
  let class = cast[LoxClass](class)

  result = newLoxInstance(class)

  let initializer = findMethod(class, "init")

  if not isNil(initializer):
    let function = `bind`(initializer, cast[LoxInstance](result))

    discard function.call(function, interpreter, arguments)
