import ./tokentype

type
  Token* = object
    kind*: TokenType
    lexeme*: string
    literal*: string # Object
    line*: int

proc initToken*(kind: TokenType, lexeme: string, literal: string, line: int): Token =
  result.kind = kind
  result.lexeme = lexeme
  result.literal = literal
  result.line = line

proc toString(token: Token): string =
  add(result, $token.kind)
  add(result, " ")
  add(result, token.lexeme)
  add(result, " ")
  add(result, token.literal)

proc `$`*(token: Token): string =
  toString(token)
