# Stdlib imports
import std/[lists, parseutils, sequtils, tables]

# Internal imports
import ./literals, ./logger, ./token, ./types

let
  keywords = {"and": And, "class": Class, "else": Else, "false": False,
              "for": For, "fun": Fun, "if": If, "nil": Nil, "or": Or,
              "print": Print, "return": Return, "super": Super, "this": This,
              "true": True, "var": Var, "while": While}.toTable
    ## A table with all keywords, where the key is the string representation and
    ## the value the `TypeToken`.

template subString(str: string, startIndex, endIndex: int): string =
  ## A template that mimics the `java.substring()` method. Performs a slice on
  ## `str`, starting at `startIndex` and ending at `endIndex - 1`. That is,
  ## `startIndex` is included and `endIndex` is excluded.
  str[startIndex..(endIndex - 1)]

proc initScanner*(source: string): Scanner =
  ## Initializes a `Scanner` object with the raw source code of `source`.
  result.source = source
  result.start = 0
  result.current = 0
  result.line = 1

proc isAtEnd(scanner: Scanner): bool =
  ## Returns `true` if the scan done in `scanner` has reached the end.
  scanner.current >= len(scanner.source)

proc advance(scanner: var Scanner): char =
  ## Advances scanning of `scanner` and returns the next character.
  result = scanner.source[scanner.current]

  inc(scanner.current)

proc addToken(scanner: var Scanner, token: var Token) =
  ## Adds `token` to list of `scanner` tokens.
  token.lexeme = newStringWithHash(substring(scanner.source, scanner.start,
                                             scanner.current))
  token.line = scanner.line

  add(scanner.tokens, token)

proc addToken(scanner: var Scanner, kind: TokenType) =
  ## Adds a token of type `kind` to the list of `scanner` tokens.
  var token = initToken(kind)

  addToken(scanner, token)

proc addToken(scanner: var Scanner, str: string) =
  ## Adds a token of type `String`, with the literal value `str`, to the list of
  ## `scanner` tokens.
  var token = initTokenString(str)

  addToken(scanner, token)

proc addToken(scanner: var Scanner, number: float) =
  ## Adds a token of type `Number`, with the literal value `number`, to the list
  ## of `scanner` tokens.
  var token = initTokenNumber(number)

  addToken(scanner, token)

proc match(scanner: var Scanner, expected: char): bool =
  ## Returns `true` if the `expected` character is next in the raw source code
  ## of `scanner`.
  if isAtEnd(scanner):
    result = false
  elif scanner.source[scanner.current] != expected:
    result = false
  else:
    result = true

    inc(scanner.current)

proc peek(scanner: Scanner): char =
  ## Peeks the first character of the raw `scanner` source code beyond the
  ## current one.
  ##
  ## Returns `\0` if the end of the raw source code of `scanner` has been
  ## reached.
  if isAtEnd(scanner):
    result = '\0'
  else:
    result = scanner.source[scanner.current]

proc peekNext(scanner: Scanner): char =
  ## Peeks the second character of the raw source code of `scanner` beyond the
  ## current one.
  ##
  ## Returns `\0` if the end of the raw source code of `scanner` has been
  ## reached.
  if scanner.current + 1 >= len(scanner.source):
    result = '\0'
  else:
    result = scanner.source[scanner.current + 1]

proc string(lox: var Lox, scanner: var Scanner) =
  ## Parses the raw source code of `scanner` and captures the string literal
  ## enclosed in double quotes, adding a `Token`, of type `String`, with its
  ## value, to the list of tokens of `scanner`.
  ##
  ## An error is printed if the final double quote of the string cannot be
  ## determined.
  while (peek(scanner) != '"') and (not isAtEnd(scanner)):
    if peek(scanner) == '\n':
      inc(scanner.line)

    discard advance(scanner)

  if isAtEnd(scanner):
    error(lox, scanner.line, "Unterminated string.")
  else:
    # The closing ".
    discard advance(scanner)

    # Trim the surrounding quotes.
    let value = subString(scanner.source, scanner.start + 1,
                          scanner.current - 1)

    addToken(scanner, value)

proc isDigit(c: char): bool =
  ## Returns `true` if the character `c` is a digit [0-9].
  c in {'0' .. '9'}

proc number(scanner: var Scanner) =
  ## Parses the raw source code of `scanner` and captures a literal number
  ## (integer or decimal), adding a `Token`, of type `Number`, with its value,
  ## in the list of tokens of `scanner`.
  while isDigit(peek(scanner)):
    discard advance(scanner)

  # Look for a fractional part.
  if (peek(scanner) == '.') and isDigit(peekNext(scanner)):
    # Consume the "."
    discard advance(scanner)

    while (isDigit(peek(scanner))):
      discard advance(scanner)

  var num: float

  discard parseFloat(scanner.source, num, scanner.start)

  addToken(scanner, num)

proc isAlpha(c: char): bool =
  ## Returns `true` if character `c` is letter or underscore [A-Z_a-z].
  c in {'A'..'Z', '_', 'a'..'z'}

proc isAlphaNumeric(c: char): bool =
  ## Returns `true` if character `c` is alphanumeric or underscore [0-9A-Z_a-z].
  isAlpha(c) or isDigit(c)

proc identifier(scanner: var Scanner) =
  ## Parses the raw source code of `scanner` and captures an identifier, which
  ## may or may not be a keyword, by adding a `Token`, of type `Identifier` or
  ## of the captured keyword, to the list of tokens of `scanner`.
  while isAlphaNumeric(peek(scanner)):
    discard advance(scanner)

  let
    text = subString(scanner.source, scanner.start, scanner.current)
    kind = getOrDefault(keywords, text, Identifier)

  addToken(scanner, kind)

proc scanToken(lox: var Lox, scanner: var Scanner) =
  ## Recognizes lexemes from the raw source code of `scanner`.
  let c = advance(scanner)

  case c
  of '(':
    addToken(scanner, LeftParen)
  of ')':
    addToken(scanner, RightParen)
  of '{':
    addToken(scanner, LeftBrace)
  of '}':
    addToken(scanner, RightBrace)
  of ',':
    addToken(scanner, Comma)
  of '.':
    addToken(scanner, Dot)
  of '-':
    addToken(scanner, Minus)
  of '+':
    addToken(scanner, Plus)
  of ';':
    addToken(scanner, Semicolon)
  of '*':
    addToken(scanner, Star)
  of '!':
    let kind = if match(scanner, '='): BangEqual
               else: Bang
    addToken(scanner, kind)
  of '=':
    let kind = if match(scanner, '='): EqualEqual
               else: Equal
    addToken(scanner, kind)
  of '<':
    let kind = if match(scanner, '='): LessEqual
               else: Less
    addToken(scanner, kind)
  of '>':
    let kind = if match(scanner, '='): GreaterEqual
               else: Greater
    addToken(scanner, kind)
  of '/':
    if match(scanner, '/'):
      # A comment goes until the end of the line.
      while (peek(scanner) != '\n') and (not isAtEnd(scanner)):
        discard advance(scanner)
    else:
      addToken(scanner, Slash)
  of ' ', '\r', '\t':
    # Ignore whitespace.
    discard
  of '\n':
    inc(scanner.line)
  of '"':
    string(lox, scanner)
  else:
    if isDigit(c):
      number(scanner)
    elif isAlpha(c):
      identifier(scanner)
    else:
      error(lox, scanner.line, "Unexpected character.")

proc scanTokens*(lox: var Lox, scanner: var Scanner): seq[Token] =
  ## Returns a `seq[Token]` with all tokens scanned from the raw source code of
  ## `scanner`.
  while not isAtEnd(scanner):
    # We are at the beginning of the next lexeme.
    scanner.start = scanner.current
    scanToken(lox, scanner)

  add(scanner.tokens, Token(kind: Eof, literal: nil,
                            lexeme: newStringWithHash(""), line: scanner.line))

  result = toSeq(scanner.tokens)
