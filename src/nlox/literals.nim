# Stdlib imports
import std/hashes

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

proc newStringWithHash*(data: static[string]): String =
  ## Creates a `String` object with the value of `data`
  String(data: data, hash: static(hash(data)))

proc newStringWithHash*(data: string): String =
  ## Creates a `String` object with the value of `data`
  String(data: data, hash: hash(data))
