import ./token, ./tokentype

type
  Scanner* = object
    source: string
    tokens: seq[Token]
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

proc scanToken() =
  discard

proc scanTokens*(scanner: var Scanner): seq[Token] =
  while not isAtEnd(scanner):
    # We are at the beginning of the next lexeme.
    scanner.start = scanner.current
    scanToken()

  add(scanner.tokens, initToken(EOF, "", "", scanner.line))
