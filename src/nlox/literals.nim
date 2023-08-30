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
