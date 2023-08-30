# Internal imports
import ./astprinter, ./logger, ./parser, ./scanner

proc run(source: string) =
  ## Initializes a `Scanner` object with the raw `source` code, scans the
  ## `Scanner` object, parses the scanned tokens and prints the parsed
  ## expression. If an error occurred, it returns without printing the
  ## expression.
  var scanner = initScanner(source)

  let tokens = scanTokens(scanner)

  var parser = initParser(tokens)

  let expression = parse(parser)

  if hadError:
    return

  echo print(expression)

proc runFile(path: string) =
  ## Runs the .lox script passed in `path`.
  let bytes = readFile(path)

  run(bytes)

  if hadError:
    quit(65)

proc runPrompt() =
  ## Runs the interactive prompt (REPL). If CTRL + D is sent, the execution will
  ## end.
  while true:
    write(stdout, "> ")

    let line = readLine(stdin)

    if line == "\4": # Ctrl + D
      break

    run(line)

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
