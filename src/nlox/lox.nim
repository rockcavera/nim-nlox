# Internal imports
import ./interpreter, ./parser, ./resolver, ./scanner, ./types

proc initLox*(): Lox =
  ## Initializes an `Lox` object.
  result.interpreter = initInterpreter()
  result.hadError = false
  result.hadRuntimeError = false

proc run(lox: var Lox, source: string) =
  ## Initializes a `Scanner` object with the raw `source` code, scans the
  ## `Scanner` object, parses the scanned tokens and interprets the parsed
  ## statements. If an error occurred, it returns without interpreting.
  var scanner = initScanner(source)

  let tokens = scanTokens(lox, scanner)

  var parser = initParser(tokens)

  let statements = parse(lox, parser)

  var resolver = initResolver()

  resolve(lox, resolver, statements)

  if lox.hadError:
    return

  interpret(lox, statements)

proc runFile(path: string) =
  ## Runs the .lox script passed in `path`.
  let bytes = readFile(path)

  var lox = initLox()

  run(lox, bytes)

  if lox.hadError:
    quit(65)

  if lox.hadRuntimeError:
    quit(70)

proc runPrompt() =
  ## Runs the interactive prompt (REPL). If CTRL + D is sent, the execution will
  ## end.
  var lox = initLox()

  while true:
    write(stdout, "> ")

    let line = readLine(stdin)

    if line == "\4": # Ctrl + D
      break

    run(lox, line)

    lox.hadError = false

proc main*(args: seq[string]) =
  ## Runs the script.lox passed in `args[0]` or runs in interactive prompt mode
  ## (REPL) when `len(args) == 0`. If `len(args) > 1`, execution will terminate
  ## and return code 64.
  if len(args) > 1:
    echo "Usage: lox [script]"

    quit(64)
  elif len(args) == 1:
    runFile(args[0])
  else:
    runPrompt()
