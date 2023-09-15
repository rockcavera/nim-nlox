import std/times

import ./environment, ./literals, ./types

proc clockArity(caller: LoxCallable): int = 0

proc clockCall(caller: LoxCallable, interpreter: var Interpreter,
               arguments: seq[Object]): Object =
  let
    currentTime = getTime()
    seconds = float(toUnix(currentTime))
    milliseconds = float(convert(Nanoseconds, Milliseconds,
                                  nanosecond(currentTime))) / 1000.0

  result = newNumber(seconds + milliseconds)

proc clockToString(caller: LoxCallable): string = "<native fn>"

proc defineClock(interpreter: var Interpreter) =
  ## Defines the built-in function `clock()`
  var clock = new(LoxCallable)

  clock.arity = clockArity
  clock.call = clockCall
  clock.toString = clockToString

  define(interpreter.globals, "clock", clock)

proc defineAllNativeFunctions*(interpreter: var Interpreter) =
  ## Define all native functions
  defineClock(interpreter)
