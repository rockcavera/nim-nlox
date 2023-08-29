# Stdlib imports
import std/[math, strformat]

# Internal imports
import ./tokentype

type
  LiteralKind* = enum
    ## Enumerates the kinds of literals.
    LitNull, LitNumber, LitString, LitBoolean

  LiteralValue* = object
    ## Object to store a literal value, which can be Number or String.
    case kind*: LiteralKind
    of LitNumber:
      numberLit*: float
        ## Stores the value of the Number
    of LitString:
      stringLit*: string
        ## Stores the value of a String
    of LitBoolean:
      booleanLit*: bool
        ## Stores the value of a Boolean
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
  Token(kind: kind, literal: LiteralValue(kind: LitNull), lexeme: "", line: -1)

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

proc stringifyLitNumber(number: float): string =
  ## Stringify a Number.
  let truncated = trunc(number)

  if truncated == number:
    result = $uint64(number)
  else:
    result = $number

proc toString(lit: LiteralValue): string =
  ## Returns a string from the `LiteralValue` object.
  ##
  ## When the decimal part of Number is 0, returns only the integer part.
  result = case lit.kind
           of LitNumber: stringifyLitNumber(lit.numberLit)
           of LitString: lit.stringLit
           of LitBoolean: $lit.booleanLit
           of LitNull: "nil"

proc toString2(lit: LiteralValue): string =
  ## Returns a string from the `LiteralValue` object.
  result = case lit.kind
           of LitNumber: $lit.numberLit
           of LitString: lit.stringLit
           of LitBoolean: $lit.booleanLit
           of LitNull: "null"

proc `$`*(lit: LiteralValue): string =
  ## Stringify operator that returns a string from the `LiteralValue` object.
  toString(lit)

proc toString(token: Token): string =
  ## Returns a string from the `Token` object.
  fmt"{token.kind} {token.lexeme} {toString2(token.literal)}"

proc `$`*(token: Token): string =
  ## Stringify operator that returns a string from the `Token` object.
  toString(token)
