# Internal imports
import ./types

proc newRuntimeError*(token: Token, message: string): ref RuntimeError =
  ## Returns a `RuntimeError` exception object with the `token` and `message`.
  new(result)

  result.msg = message
  result.parent = nil
  result.token = token
