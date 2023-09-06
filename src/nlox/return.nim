# Internal imports
import ./types

proc newReturn*(value: Object): ref Return =
  ## Create a `Return` with `value`.
  new(result)

  result.parent = nil
  result.value = value
