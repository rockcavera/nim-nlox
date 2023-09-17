# Stdlib imports
import std/[math, strformat, strutils]

# Internal imports
import ./types

method toString*(obj: Object, isEvaluation: bool): string {.base.} =
  ## Base method that raises `CatchableError` exception when `obj` has not had
  ## its method implemented.
  raise newException(CatchableError, "Method without implementation override")

method toString*(obj: Boolean, isEvaluation: bool): string =
  ## Returns a `string` of `obj`.
  $obj.data

method toString*(obj: Number, isEvaluation: bool): string =
  ## Returns a `string` of `obj`.
  result = $obj.data

  if isEvaluation:
    if endsWith(result, ".0"):
      setLen(result, len(result) - 2)
    elif isNaN(obj.data):
      result = "NaN"

method toString*(obj: String, isEvaluation: bool): string =
  ## Returns a `string` of `obj`.
  obj.data

method toString*(obj: LoxCallable, isEvaluation: bool): string =
  ## Returns a `string` of `obj`.
  obj.toString(obj)

method toString*(obj: LoxInstance, isEvaluation: bool): string =
  ## Returns a `string` of `obj`.
  fmt"{obj.klass.name} instance"
