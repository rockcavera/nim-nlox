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
