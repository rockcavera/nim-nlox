import ./logger, ./token, ./tokentype

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
    let value = scanner.source[(scanner.start + 1)..(scanner.current - 1)]

    addToken(scanner, String, value)

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
    error(scanner.line, "Unexpected character.")

proc scanTokens*(scanner: var Scanner): seq[Token] =
  while not isAtEnd(scanner):
    # We are at the beginning of the next lexeme.
    scanner.start = scanner.current
    scanToken(scanner)

  add(scanner.tokens, initToken(EOF, "", "", scanner.line))
