# Refactoring required due to impossibility of cyclic imports in Nim

# Stdlib imports
import std/strformat

# Internal imports
import ./types

# From src/lox.nim

proc report(lox: var Lox, line: int, where: string, message: string) =
  ## `error()` helper procedure.
  echo fmt"[line {line}] Error{where}: {message}"

  lox.hadError = true

proc error*(lox: var Lox, token: Token, message: string) =
  ## Reports that an error occurred in a particular token `token`. The location
  ## of the token, the token itself and a `message` message will be printed.
  if token.kind == Eof:
    report(lox, token.line, " at end", message)
  else:
    report(lox, token.line, fmt" at '{token.lexeme.data}'", message)

proc error*(lox: var Lox, line: int, message: string) =
  ## Reports that a syntax error occurred on a given `line` printing a
  ## `message`.
  report(lox, line, "", message)

proc runtimeError*(lox: var Lox, error: RuntimeError) =
  ## Reports a runtime error by providing the line of code that was executing
  ## when the error occurred.
  echo fmt"{error.msg}{'\n'}[line {error.token.line}]"

  lox.hadRuntimeError = true

# End src/lox.nim
