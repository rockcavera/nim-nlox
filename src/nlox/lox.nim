import std/[lists, strformat]

import ./token

type
  Scanner = object

var
  hadError* = false

proc scanTokens(scanner: Scanner): SinglyLinkedList[Token] =
  discard

proc report(line: int, where: string, message: string) =
  echo fmt"[line {line}] Error{where}: {message}"

  hadError = true

proc error*(line: int, message: string) =
  report(line, "", message)

proc run(source: string) =
  var
    scanner: Scanner # = new Scanner(source)
    tokens = scanTokens(scanner)

  for token in tokens:
    echo token

proc runFile(path: string) =
  let bytes = readFile(path)

  run(bytes)

  if hadError:
    quit(65)

proc runPrompt() =
  while true:
    write(stdout, "> ")

    let line = readLine(stdin)

    if line == "\4": # Ctrl + D
      break

    run(line)

    hadError = false

proc main*(args: seq[string]) =
  if len(args) > 1:
    echo "Usage: lox [script]"

    quit(64)
  elif len(args) == 1:
    runFile(args[0])
  else:
    runPrompt()
