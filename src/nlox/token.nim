# Stdlib imports
import std/strformat

# Internal imports
import ./tokentype

type
  Token* = object
    ## Object that stores token information.
    ##
    ## For convenience, object variants have been used instead of a `literal`
    ## field.
    case kind*: TokenType
      ## Stores the type of token.
    of Number:
      numberLit*: float
        ## Stores the value of the number
    of String:
      stringLit*: string
        ## Stores the value of a string
    else:
      discard
    lexeme*: string
      ## Stores the lexeme.
    line*: int
      ## Stores the token line.

proc initToken*(kind: TokenType): Token =
  ## Initializes a `Token` as `TokenType`.`kind`. The `lexeme` and `line` fields
  ## are initialized to `""` and `-1`, respectively.
  Token(kind: kind, lexeme: "", line: -1)

proc initTokenNumber*(numberLit: float): Token =
  ## Initialize a `Token` as `TokenType.Number` and the field `Token.numberLit`
  ## as `numberLit`. The `lexeme` and `line` fields are initialized to `""` and
  ## `-1`, respectively.
  Token(kind: Number, numberLit: numberlit, lexeme: "", line: -1)

proc initTokenString*(stringLit: string): Token =
  ## Initialize a `Token` as `TokenType.String` and the field `Token.stringLit`
  ## as `stringLit`. The `lexeme` and `line` fields are initialized to `""` and
  ## `-1`, respectively.
  Token(kind: String, stringLit: stringLit, lexeme: "", line: -1)

proc toString(token: Token): string =
  ## Returns a string from the `Token` object.
  let literal = case token.kind
                of Number: $token.numberLit
                of String: token.stringLit
                else: "null"

  result = fmt"{token.kind} {token.lexeme} {literal}"

proc `$`*(token: Token): string =
  ## Stringify operator that returns a string from the `Token` object.
  toString(token)
