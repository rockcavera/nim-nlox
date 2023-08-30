# Refactoring required due to impossibility of cyclic imports in Nim

# Stdlib imports
import std/strformat

# Internal imports
import ./runtimeerror, ./token, ./tokentype

# From src/lox.nim

var
  hadError* = false
    ## Determines if an error occurred in code execution.
  hadRuntimeError* = false

proc report(line: int, where: string, message: string) =
  ## `error()` helper procedure.
  echo fmt"[line {line}] Error{where}: {message}"

  hadError = true

proc error*(token: Token, message: string) =
  ## Reports that an error occurred in a particular token `token`. The location
  ## of the token, the token itself and a `message` message will be printed.
  if token.kind == Eof:
    report(token.line, " at end", message)
  else:
    report(token.line, fmt" at '{token.lexeme}'", message)

proc error*(line: int, message: string) =
  ## Reports that a syntax error occurred on a given `line` printing a
  ## `message`.
  report(line, "", message)

proc runtimeError*(error: ref RuntimeError) =
  echo fmt"{error.msg}{'\n'}[line {error.token.line}]"

  hadRuntimeError = true

# End src/lox.nim
