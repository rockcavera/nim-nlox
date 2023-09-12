# Internal imports
import ./types

type
  Return* = object of CatchableError
    ## Object used to unroll the stack when return is called in Lox. It is not
    ## used to raise an error of fact.
    value*: Object
      ## The returned value.

proc newReturn*(value: Object): ref Return =
  ## Create a `Return` with `value`.
  new(result)

  result.parent = nil
  result.value = value
