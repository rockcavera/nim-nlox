# Refactoring required due to impossibility of cyclic imports in Nim
import std/strformat

# From src/lox.nim

var
  hadError* = false

proc report(line: int, where: string, message: string) =
  echo fmt"[line {line}] Error{where}: {message}"

  hadError = true

proc error*(line: int, message: string) =
  report(line, "", message)

# End src/lox.nim
