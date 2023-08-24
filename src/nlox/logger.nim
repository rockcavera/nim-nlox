# Refactoring required due to impossibility of cyclic imports in Nim

# Stdlib imports
import std/strformat

# From src/lox.nim

var
  hadError* = false
    ## Determines if an error occurred in code execution.

proc report(line: int, where: string, message: string) =
  ## `error()` helper procedure.
  echo fmt"[line {line}] Error{where}: {message}"

  hadError = true

proc error*(line: int, message: string) =
  ## Reports that a syntax error occurred on a given `line` printing a
  ## `message`.
  report(line, "", message)

# End src/lox.nim
