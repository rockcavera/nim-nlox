# Internal imports
import ./interpreter, ./logger, ./parser, ./scanner, ./types

proc run(interpreter: var Interpreter, source: string) =
  ## Initializes a `Scanner` object with the raw `source` code, scans the
  ## `Scanner` object, parses the scanned tokens and interprets the parsed
  ## statements. If an error occurred, it returns without interpreting.
  var scanner = initScanner(source)

  let tokens = scanTokens(scanner)

  var parser = initParser(tokens)

  let statements = parse(parser)

  if hadError:
    return

  interpret(interpreter, statements)

proc runFile(path: string) =
  ## Runs the .lox script passed in `path`.
  let bytes = readFile(path)

  var interpreter = initInterpreter()

  run(interpreter, bytes)

  if hadError:
    quit(65)

  if hadRuntimeError:
    quit(70)

proc runPrompt() =
  ## Runs the interactive prompt (REPL). If CTRL + D is sent, the execution will
  ## end.
  var interpreter = initInterpreter()

  while true:
    write(stdout, "> ")

    let line = readLine(stdin)

    if line == "\4": # Ctrl + D
      break

    run(interpreter, line)

    hadError = false

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
