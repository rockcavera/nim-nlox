# Stdlib imports
import std/times

# Internal imports
import ./environment, ./literals, ./types

proc clockArity(caller: LoxCallable): int = 0
  ## `arity` for "clock()" .

when defined(nloxBenchmark):
  import std/monotimes

  proc clockCall(caller: LoxCallable, interpreter: var Interpreter,
                 arguments: seq[Object]): Object =
    ## `call` for "clock()".
    let
      current = ticks(getMonoTime())
      milliseconds = float(convert(Nanoseconds, Milliseconds,current))

    result = newNumber(milliseconds / 1000.0)
else:
  proc clockCall(caller: LoxCallable, interpreter: var Interpreter,
                 arguments: seq[Object]): Object =
    ## `call` for "clock()".
    let
      currentTime = getTime()
      seconds = float(toUnix(currentTime))
      milliseconds = float(convert(Nanoseconds, Milliseconds,
                                   nanosecond(currentTime))) / 1000.0

    result = newNumber(seconds + milliseconds)

proc clockToString(caller: LoxCallable): string = "<native fn>"
  ## `toString` for "clock()".

proc defineClock(interpreter: var Interpreter) =
  ## Defines the built-in function `clock()`.
  var clock = new(LoxCallable)

  clock.arity = clockArity
  clock.call = clockCall
  clock.toString = clockToString

  define(interpreter.globals, "clock", clock)

proc defineAllNativeFunctions*(interpreter: var Interpreter) =
  ## Define all native functions.
  defineClock(interpreter)
