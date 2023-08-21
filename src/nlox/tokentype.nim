type
  TokenType* = enum
    # Single-character tokens.
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,
    Comma,
    Dot,
    Minus,
    Plus,
    Semicolon,
    Slash,
    Star,
    # One or two character tokens.
    Bang,
    BangEqual,
    Equal,
    EqualEqual,
    Greater,
    GreaterEqual,
    Less,
    LessEqual,
    # Literals.
    Identifier,
    String,
    Number,
    # Keywords.
    And,
    Class,
    Else,
    False,
    Fun,
    For,
    If,
    Nil,
    Or,
    Print,
    Return,
    Super,
    This,
    True,
    Var,
    While,

    Eof

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
