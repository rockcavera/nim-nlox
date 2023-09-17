# Internal imports
import ./types

proc newRuntimeError*(token: Token, message: string): RuntimeError =
  ## Returns a `RuntimeError` exception object with the `token` and `message`.
  RuntimeError(msg: message, parent: nil, token: token)
