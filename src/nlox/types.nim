# Stdlib imports
import std/[lists, tables]

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

  TokenType* = enum
    ## Enumerator of all possible token types
    # Single-character tokens.
    LeftParen,    # (
    RightParen,   # )
    LeftBrace,    # {
    RightBrace,   # }
    Comma,        # ,
    Dot,          # .
    Minus,        # -
    Plus,         # +
    Semicolon,    # ;
    Slash,        # /
    Star,         # *
    # One or two character tokens.
    Bang,         # !
    BangEqual,    # !=
    Equal,        # =
    EqualEqual,   # ==
    Greater,      # >
    GreaterEqual, # >=
    Less,         # <
    LessEqual,    # <=
    # Literals.
    Identifier,   # [A-Z_a-z][0-9A-Z_a-z]*
    String,       # "string" | ""
    Number,       # 123 | 123.0
    # Keywords.
    And,          # and
    Class,        # class
    Else,         # else
    False,        # false
    Fun,          # fun
    For,          # for
    If,           # if
    Nil,          # nil
    Or,           # or
    Print,        # print
    Return,       # return
    Super,        # super
    This,         # this
    True,         # true
    Var,          # var
    While,        # while

    Eof           # End-of-file

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

  Scanner* = object
    ## Object that stores scanner information.
    source*: string
      ## Stores raw source code.
    tokens*: SinglyLinkedList[Token]
      ## Stores a list of all parsed tokens from raw source code.
    start*: int
      ## Points to the first character in the lexeme.
    current*: int
      ## Points at the character currently being considered.
    line*: int
      ## The line that is being scanned.

  Parser* = object
    ## Object that stores parser information.
    tokens*: seq[Token]
      ## Sequence of tokens.
    current*: int
      ## Index of next token waiting for parsing.

  Environment* = ref object
    ## Object that stores the variables
    enclosing*: Environment
      ## Reference to the outer level environment. For the global environment
      ## this is `nil`.
    values*: Table[string, LiteralValue]
      ## Hash table that stores variable names and values.

  ParseError* = object of CatchableError
    ## Raised if a parsing error occurred.

  RuntimeError* = object of CatchableError
    ## Raised if a runtime error occurred.
    token*: Token
      ## The `Token` is used to tell which line of code was running when the
      ## error occurred.
