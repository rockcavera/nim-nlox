# Internal imports
import ./token

type
  RuntimeError* = object of CatchableError
    ## Raised if a runtime error occurred.
    token*: Token
      ## The `Token` is used to tell which line of code was running when the
      ## error occurred.

proc newRuntimeError*(token: Token, message: string): ref RuntimeError =
  ## Returns a `RuntimeError` exception object with the `token` and `message`.
  new(result)

  result.msg = message
  result.parent = nil
  result.token = token
