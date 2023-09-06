import ./types

proc newReturn*(value: Object): ref Return =
  new(result)

  result.parent = nil
  result.value = value
