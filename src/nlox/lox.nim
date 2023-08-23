import ./log, ./scanner, ./token

proc run(source: string) =
  var
    scanner = initScanner(source)
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
