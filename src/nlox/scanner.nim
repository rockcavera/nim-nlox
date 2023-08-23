import std/[lists, strutils, tables]

import ./logger, ./token, ./tokentype

type
  Scanner* = object
    source: string
    tokens: SinglyLinkedList[Token]
    start: int ## points to the first character in the lexeme
    current: int ## points at the character currently being considered
    line: int

let
  keywords = {"and": And, "class": Class, "else": Else, "false": False,
              "for": For, "fun": Fun, "if": If, "nil": Nil, "or": Or,
              "print": Print, "return": Return, "super": Super, "this": This,
              "true": True, "var": Var, "while": While}.toTable

template subString(str: string, startIndex, endIndex: int): string =
  str[startIndex..(endIndex - 1)]

proc initScanner*(source: string): Scanner =
  result.source = source
  result.start = 0
  result.current = 0
  result.line = 1

proc isAtEnd(scanner: Scanner): bool =
  result = scanner.current >= len(scanner.source)

proc advance(scanner: var Scanner): char =
  result = scanner.source[scanner.current]

  inc(scanner.current)

proc addToken(scanner: var Scanner, token: var Token) =
  token.lexeme = substring(scanner.source, scanner.start, scanner.current)
  token.line = scanner.line

  add(scanner.tokens, token)

proc addToken(scanner: var Scanner, kind: TokenType) =
  var token = initToken(kind)

  addToken(scanner, token)

proc addToken(scanner: var Scanner, str: string) =
  var token = initTokenString(str)

  addToken(scanner, token)

proc addToken(scanner: var Scanner, number: float) =
  var token = initTokenNumber(number)

  addToken(scanner, token)

proc match(scanner: var Scanner, expected: char): bool =
  if isAtEnd(scanner):
    result = false
  elif scanner.source[scanner.current] != expected:
    result = false
  else:
    result = true

    inc(scanner.current)

proc peek(scanner: Scanner): char =
  if isAtEnd(scanner):
    result = '\0'
  else:
    result = scanner.source[scanner.current]

proc peekNext(scanner: Scanner): char =
  if scanner.current + 1 >= len(scanner.source):
    result = '\0'
  else:
    result = scanner.source[scanner.current + 1]

proc string(scanner: var Scanner) =
  while (peek(scanner) != '"') and (not isAtEnd(scanner)):
    if peek(scanner) == '\n':
      inc(scanner.line)

    discard advance(scanner)

  if isAtEnd(scanner):
    error(scanner.line, "Unterminated string.")
  else:
    # The closing ".
    discard advance(scanner)

    # Trim the surrounding quotes.
    let value = subString(scanner.source, scanner.start + 1, scanner.current - 1)

    addToken(scanner, value)

proc isDigit(c: char): bool =
  result = c in {'0' .. '9'}

proc number(scanner: var Scanner) =
  while isDigit(peek(scanner)):
    discard advance(scanner)

  # Look for a fractional part.
  if (peek(scanner) == '.') and isDigit(peekNext(scanner)):
    # Consume the "."
    discard advance(scanner)

    while (isDigit(peek(scanner))):
      discard advance(scanner)

  addToken(scanner, parseFloat(subString(scanner.source, scanner.start, scanner.current)))

proc isAlpha(c: char): bool =
  result = c in {'A'..'Z', '_', 'a'..'z'}

proc isAlphaNumeric(c: char): bool =
  result = isAlpha(c) or isDigit(c)

proc identifier(scanner: var Scanner) =
  while isAlphaNumeric(peek(scanner)):
    discard advance(scanner)

  let
    text = subString(scanner.source, scanner.start, scanner.current)
    kind = getOrDefault(keywords, text, Identifier)

  addToken(scanner, kind)

proc scanToken(scanner: var Scanner) =
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
    string(scanner)
  else:
    if isDigit(c):
      number(scanner)
    elif isAlpha(c):
      identifier(scanner)
    else:
      error(scanner.line, "Unexpected character.")

proc scanTokens*(scanner: var Scanner): SinglyLinkedList[Token] =
  while not isAtEnd(scanner):
    # We are at the beginning of the next lexeme.
    scanner.start = scanner.current
    scanToken(scanner)

  addToken(scanner, Eof)

  result = scanner.tokens
