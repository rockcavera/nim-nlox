# Stdlib imports
import std/exitprocs

# Internal imports
import ./interpreter, ./parser, ./resolver, ./scanner, ./types

proc initLox*(): Lox =
  ## Initializes an `Lox` object.
  result.interpreter = initInterpreter()
  result.hadError = false
  result.hadRuntimeError = false

proc run(lox: var Lox, source: string) =
  ## Initializes a `Scanner` object with the raw `source` code, checks the
  ## `Scanner` object, parses the checked tokens, if no error occurred, resolves
  ## the statements. Finally, if there was no error in the previous process, it
  ## interprets the statements.
  var scanner = initScanner(source)

  let tokens = scanTokens(lox, scanner)

  var parser = initParser(tokens)

  let statements = parse(lox, parser)

  if not lox.hadError:
    var resolver = initResolver()

    resolve(lox, resolver, statements)

    if not lox.hadError:
      interpret(lox, statements)

proc runFile(path: string) =
  ## Runs the .lox script passed in `path`.
  let bytes = readFile(path)

  var lox = initLox()

  run(lox, bytes)

  lox.interpreter.environment.values = nil # Without this line, Valgrind claims
                                           # a memory leak

  if lox.hadError:
    setProgramResult(65)
  elif lox.hadRuntimeError:
    setProgramResult(70)

proc runPrompt() =
  ## Runs the interactive prompt (REPL). If CTRL + D, on Unix, or CTRL + Z, on
  ## Windows, is sent, the execution will end.
  var lox = initLox()

  while true:
    write(stdout, "> ")

    var line: string

    if not readLine(stdin, line):
      break

    run(lox, line)

    lox.hadError = false

proc main*(args: seq[string]) =
  ## Runs the script.lox passed in `args[0]` or runs in interactive prompt mode
  ## (REPL) when `len(args) == 0`. If `len(args) > 1`, execution will terminate
  ## and return code 64.
  if len(args) > 1:
    echo "Usage: lox [script]"

    setProgramResult(64)
  elif len(args) == 1:
    runFile(args[0])
  else:
    runPrompt()
