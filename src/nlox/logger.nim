# Refactoring required due to impossibility of cyclic imports in Nim

# Stdlib imports
import std/strformat

import ./token, ./tokentype

# From src/lox.nim

var
  hadError* = false
    ## Determines if an error occurred in code execution.

proc report(line: int, where: string, message: string) =
  ## `error()` helper procedure.
  echo fmt"[line {line}] Error{where}: {message}"

  hadError = true

proc error*(token: Token, message: string) =
  if token.kind == Eof:
    report(token.line, " at end", message)
  else:
    report(token.line, fmt" at '{token.lexeme}'", message)

proc error*(line: int, message: string) =
  ## Reports that a syntax error occurred on a given `line` printing a
  ## `message`.
  report(line, "", message)

# End src/lox.nim
