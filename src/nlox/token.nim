# Stdlib imports
import std/strformat

# Internal imports
import ./tokentype

type
  LiteralKind* = enum
    ## Enumerates the kinds of literals.
    LitNone, LitNumber, LitString

  LiteralValue* = object
    ## Object to store a literal value, which can be Number or String.
    case kind*: LiteralKind
    of LitNumber:
      numberLit*: float
        ## Stores the value of the Number
    of LitString:
      stringLit*: string
        ## Stores the value of a String
    else:
      discard

  Token* = object
    ## Object that stores token information.
    ##
    ## For convenience, object variants have been used instead of a `literal`
    ## field.
    kind*: TokenType
      ## Stores the type of token.
    literal*: LiteralValue
      ## Stores a literal value, which can be Number or String.
    lexeme*: string
      ## Stores the lexeme.
    line*: int
      ## Stores the token line.

proc initToken*(kind: TokenType): Token =
  ## Initializes a `Token` as `TokenType`.`kind`. The `lexeme` and `line` fields
  ## are initialized to `""` and `-1`, respectively.
  Token(kind: kind, literal: LiteralValue(kind: LitNone), lexeme: "", line: -1)

proc initTokenNumber*(numberLit: float): Token =
  ## Initialize a `Token` as `TokenType.Number` and the field `Token.numberLit`
  ## as `numberLit`. The `lexeme` and `line` fields are initialized to `""` and
  ## `-1`, respectively.
  Token(kind: Number, literal: LiteralValue(kind: LitNumber,
                                            numberLit: numberlit), lexeme: "",
                                            line: -1)

proc initTokenString*(stringLit: string): Token =
  ## Initialize a `Token` as `TokenType.String` and the field `Token.stringLit`
  ## as `stringLit`. The `lexeme` and `line` fields are initialized to `""` and
  ## `-1`, respectively.
  Token(kind: String, literal: LiteralValue(kind: LitString,
                                            stringLit: stringLit), lexeme: "",
                                            line: -1)

proc toString(lit: LiteralValue): string =
  ## Returns a string from the `LiteralValue` object.
  result = case lit.kind
           of LitNumber: $lit.numberLit
           of LitString: lit.stringLit
           else: "null"

proc toString(token: Token): string =
  ## Returns a string from the `Token` object.
  fmt"{token.kind} {token.lexeme} {toString(token.literal)}"

proc `$`*(token: Token): string =
  ## Stringify operator that returns a string from the `Token` object.
  toString(token)
