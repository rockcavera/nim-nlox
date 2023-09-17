# Internal imports
import ./types

type
  Return* = ref object of CatchableError
    ## Object used to unroll the stack when return is called in Lox. It is not
    ## used to raise an error of fact.
    value*: Object
      ## The returned value.

proc newReturn*(value: Object): Return =
  ## Create a `Return` with `value`.
  Return(parent: nil, value: value)
