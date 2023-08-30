{.used.}
import std/private/[ospaths2], std/unittest

import nlox/[scanner, token]

import ./tconfig

const folder = "scanning"

proc scanningTest(scriptFile: string): string =
  let source = readFile(loxScriptsFolder / scriptFile)

  var scanner = initScanner(source)

  let tokens = scanTokens(scanner)

  for token in tokens:
    add(result, $token)
    add(result, '\n')

suite "Scanning":
  test "Identifiers":
    const
      script = folder / "identifiers.lox"
      expectedOutput = """Identifier andy null
Identifier formless null
Identifier fo null
Identifier _ null
Identifier _123 null
Identifier _abc null
Identifier ab123 null
Identifier abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_ null
Eof  null
"""
    check expectedOutput == scanningTest(script)

  test "Keywords":
    const
      script = folder / "keywords.lox"
      expectedOutput = """And and null
Class class null
Else else null
False false null
For for null
Fun fun null
If if null
Nil nil null
Or or null
Return return null
Super super null
This this null
True true null
Var var null
While while null
Eof  null
"""

    check expectedOutput == scanningTest(script)

  test "Numbers":
    const
      script = folder / "numbers.lox"
      expectedOutput = """Number 123 123.0
Number 123.456 123.456
Dot . null
Number 456 456.0
Number 123 123.0
Dot . null
Eof  null
"""

    check expectedOutput == scanningTest(script)

  test "Punctuators":
    const
      script = folder / "punctuators.lox"
      expectedOutput = """LeftParen ( null
RightParen ) null
LeftBrace { null
RightBrace } null
Semicolon ; null
Comma , null
Plus + null
Minus - null
Star * null
BangEqual != null
EqualEqual == null
LessEqual <= null
GreaterEqual >= null
BangEqual != null
Less < null
Greater > null
Slash / null
Dot . null
Eof  null
"""

    check expectedOutput == scanningTest(script)

  test "Strings":
    const
      script = folder / "strings.lox"
      expectedOutput = "String \"\" \nString \"string\" string\nEof  null\n"

    check expectedOutput == scanningTest(script)

  test "Whitespace":
    const
      script = folder / "whitespace.lox"
      expectedOutput = """Identifier space null
Identifier tabs null
Identifier newlines null
Identifier end null
Eof  null
"""

    check expectedOutput == scanningTest(script)
