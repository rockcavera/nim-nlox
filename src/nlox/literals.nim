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

proc initLiteral*(): LiteralValue =
  ## Initializes a `LiteralValue` object of kind `LitNull`
  LiteralValue(kind: LitNull)

proc initLiteralNumber*(numberLit: float): LiteralValue =
  ## Initializes a `LiteralValue` object of kind `LitNumber` with the value
  ## `numberLit`.
  LiteralValue(kind: LitNumber, numberLit: numberLit)

proc initLiteralString*(stringLit: string): LiteralValue =
  ## Initializes a `LiteralValue` object of kind `LitString` with the value
  ## `stringLit`.
  LiteralValue(kind: LitString, stringLit: stringLit)

proc initLiteralBoolean*(booleanLit: bool): LiteralValue =
  ## Initializes a `LiteralValue` object of kind `LitBoolean` with the value
  ## `booleanLit`.
  LiteralValue(kind: LitBoolean, booleanLit: booleanLit)

proc toString(lit: LiteralValue): string =
  ## Returns a string from the `LiteralValue` object.
  result = case lit.kind
           of LitNumber: $lit.numberLit
           of LitString: lit.stringLit
           of LitBoolean: $lit.booleanLit
           of LitNull: "null"

proc `$`*(lit: LiteralValue): string =
  ## Stringify operator that returns a string from the `LiteralValue` object.
  toString(lit)
