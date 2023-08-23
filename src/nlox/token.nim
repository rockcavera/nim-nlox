import ./tokentype

type
  Token* = object
    case kind*: TokenType
    of Number:
      numberLit*: float
    of String:
      stringLit*: string
    else:
      discard
    lexeme*: string
    #literal*: string # Object
    line*: int

proc initToken*(kind: TokenType): Token =
  Token(kind: kind, lexeme: "", line: -1)

proc initTokenNumber*(numberLit: float): Token =
  Token(kind: Number, numberLit: numberlit, lexeme: "", line: -1)

proc initTokenString*(stringLit: string): Token =
  Token(kind: String, stringLit: stringLit, lexeme: "", line: -1)

proc toString(token: Token): string =
  add(result, $token.kind)
  add(result, " ")
  add(result, token.lexeme)
  add(result, " ")
  case token.kind
  of Number:
    add(result, $token.numberLit)
  of String:
    add(result, token.stringLit)
  else:
    add(result, "nil") # ?

proc `$`*(token: Token): string =
  toString(token)
