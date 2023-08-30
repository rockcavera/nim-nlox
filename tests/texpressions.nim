{.used.}
import std/private/[ospaths2], std/unittest

import nlox/[astprinter, logger, parser, scanner]

import ./tconfig

const folder = "expressions"

proc expressionsTest(scriptFile: string): string =
  let source = readFile(loxScriptsFolder / scriptFile)

  var scanner = initScanner(source)

  let tokens = scanTokens(scanner)

  var parser = initParser(tokens)

  let expression = parse(parser)

  if not hadError:
    result = print(expression)

suite "Expressions":
  test "Parse":
    const
      script = folder / "parse.lox"
      expectedOutput = """(+ (group (- 5.0 (group (- 3.0 1.0)))) (- 1.0))"""

    check expectedOutput == expressionsTest(script)
