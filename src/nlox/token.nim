# Stdlib imports
import std/strformat

# Internal imports
import ./literals, ./tostringobject, ./types

proc initToken*(kind: TokenType): Token =
  ## Initializes a `Token` as `TokenType`.`kind`. The `lexeme` and `line` fields
  ## are initialized to `""` and `-1`, respectively.
  Token(kind: kind, literal: nil, lexeme: nil, line: -1)

proc initTokenNumber*(numberLit: float): Token =
  ## Initialize a `Token` as `TokenType.Number` and the field `Token.numberLit`
  ## as `numberLit`. The `lexeme` and `line` fields are initialized to `""` and
  ## `-1`, respectively.
  Token(kind: TokenType.Number, literal: newNumber(numberlit), lexeme: nil,
        line: -1)

proc initTokenString*(stringLit: string): Token =
  ## Initialize a `Token` as `TokenType.String` and the field `Token.stringLit`
  ## as `stringLit`. The `lexeme` and `line` fields are initialized to `""` and
  ## `-1`, respectively.
  Token(kind: TokenType.String, literal: newString(stringLit), lexeme: nil,
        line: -1)

proc `$`(literal: Object): string =
  ## Stringify operator that returns a string from the `Object`.
  if isNil(literal): # prevents `NilAccessDefect`
    result = "null"
  else:
    result = toString(literal, false)

proc toString(token: Token): string =
  ## Returns a string from the `Token` object.
  fmt"{token.kind} {token.lexeme.data} {token.literal}"

proc `$`*(token: Token): string =
  ## Stringify operator that returns a string from the `Token` object.
  toString(token)
