# Stdlib imports
import std/strformat

# Internal imports
import ./literals, ./types

proc initToken*(kind: TokenType): Token =
  ## Initializes a `Token` as `TokenType`.`kind`. The `lexeme` and `line` fields
  ## are initialized to `""` and `-1`, respectively.
  Token(kind: kind, literal: nil, lexeme: "", line: -1)

proc initTokenNumber*(numberLit: float): Token =
  ## Initialize a `Token` as `TokenType.Number` and the field `Token.numberLit`
  ## as `numberLit`. The `lexeme` and `line` fields are initialized to `""` and
  ## `-1`, respectively.
  Token(kind: Number, literal: newNumber(numberlit), lexeme: "",
        line: -1)

proc initTokenString*(stringLit: string): Token =
  ## Initialize a `Token` as `TokenType.String` and the field `Token.stringLit`
  ## as `stringLit`. The `lexeme` and `line` fields are initialized to `""` and
  ## `-1`, respectively.
  Token(kind: String, literal: newString(stringLit), lexeme: "",
        line: -1)

proc toString(token: Token): string =
  ## Returns a string from the `Token` object.
  fmt"{token.kind} {token.lexeme} {token.literal}"

proc `$`*(token: Token): string =
  ## Stringify operator that returns a string from the `Token` object.
  toString(token)
