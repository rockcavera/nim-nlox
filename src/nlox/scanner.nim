import ./log, ./token, ./tokentype

type
  Scanner* = object
    source: string
    tokens: seq[Token] # list?
    start: int ## points to the first character in the lexeme
    current: int ## points at the character currently being considered
    line: int

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

proc addToken(scanner: var Scanner, kind: TokenType, literal: string) =
  let text = scanner.source[scanner.start..scanner.current]

  add(scanner.tokens, initToken(kind, text, literal, scanner.line))

proc addToken(scanner: var Scanner, kind: TokenType) =
  addToken(scanner, kind, "") # nil

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
  else:
    error(scanner.line, "Unexpected character.")

proc scanTokens*(scanner: var Scanner): seq[Token] =
  while not isAtEnd(scanner):
    # We are at the beginning of the next lexeme.
    scanner.start = scanner.current
    scanToken(scanner)

  add(scanner.tokens, initToken(EOF, "", "", scanner.line))
