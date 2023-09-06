{.used.}
import std/private/[ospaths2], std/unittest

import nlox/[astprinter, interpreter, lox, parser, scanner]

import ./tconfig

const folder = "expressions"

proc parseTest(scriptFile: string): string =
  let source = readFile(loxScriptsFolder / scriptFile)

  var lox = initLox()

  var scanner = initScanner(source)

  let tokens = scanTokens(lox, scanner)

  var parser = initParser(tokens)

  let expression = parseForParseTest(lox, parser)

  if not lox.hadError:
    result = print(expression)

proc evaluateTest(scriptFile: string): string =
  let source = readFile(loxScriptsFolder / scriptFile)

  var lox = initLox()

  var scanner = initScanner(source)

  let tokens = scanTokens(lox, scanner)

  var parser = initParser(tokens)

  let expression = parseForParseTest(lox, parser)

  if not lox.hadError:
    result = interpretForEvaluateTest(lox, expression)

suite "Expressions":
  test "Parse":
    const
      script = folder / "parse.lox"
      expectedOutput = """(+ (group (- 5.0 (group (- 3.0 1.0)))) (- 1.0))"""

    check expectedOutput == parseTest(script)

  test "Evaluate":
    const
      script = folder / "evaluate.lox"
      expectedOutput = """2"""

    check expectedOutput == evaluateTest(script)
