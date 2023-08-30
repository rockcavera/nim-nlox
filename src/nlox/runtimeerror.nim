import ./token

type
  RuntimeError* = object of CatchableError
    token*: Token

proc newRuntimeError*(token: Token, message: string): ref RuntimeError =
  new(result)

  result.msg = message
  result.parent = nil
  result.token = token
