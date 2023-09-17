# Internal imports
import ./types

proc newObject*(): Object =
  ## Create a null `Object`.
  discard

proc newBoolean*(data: bool): Boolean =
  ## Creates a `Boolean` object with the value of `data`
  Boolean(data: data)

proc newNumber*(data: float): Number =
  ## creates a `Number` object with the value of `data`
  Number(data: data)

proc newString*(data: string): String =
  ## Creates a `String` object with the value of `data`
  String(data: data)

method toString(literal: Object): string {.base.} =
  ## Base method that raises `CatchableError` exception when `literal` has not
  ## had its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method toString(literal: Boolean): string =
  ## Returns a `string` of `literal`.
  $literal.data

method toString(literal: Number): string =
  ## Returns a `string` of `literal`.
  $literal.data

method toString(literal: String): string =
  ## Returns a `string` of `literal`.
  literal.data

# proc toString(literal: Object): string =
#   if isNil(literal):
#     result = "null"
#   elif literal of Boolean:
#     result = $Boolean(literal).data
#   elif literal of Number:
#     result = $Number(literal).data
#   elif literal of String:
#     result = String(literal).data

proc `$`*(literal: Object): string =
  ## Stringify operator that returns a string from the `Object` object.
  if isNil(literal): # prevents `NilAccessDefect`
    result = "null"
  else:
    result = toString(literal)
