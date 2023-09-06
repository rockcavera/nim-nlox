import ./types

type
  Resolver* = object
    interpreter: Interpreter

proc initResolver*(interpreter: Interpreter): Resolver =
  result.interpreter = interpreter
