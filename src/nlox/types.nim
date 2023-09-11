# Stdlib imports
import std/[lists, tables]

type
  Object* = ref object of RootObj

  Boolean* = ref object of Object
    ## An object for Lox's Boolean type.
    data*: bool

  Number* = ref object of Object
    ## An object for Lox's Number type.
    data*: float

  String* = ref object of Object
    ## An object for Lox's String type.
    data*: string

  TokenType* {.pure.} = enum
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
    literal*: Object
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
    values*: Table[string, Object]
      ## Hash table that stores variable names and values.

  Return* = object of CatchableError
    ## Object used to unroll the stack when return is called in Lox. It is not
    ## used to raise an error of fact.
    value*: Object
      ## The returned value.

  ParseError* = object of CatchableError
    ## Raised if a parsing error occurred.

  RuntimeError* = object of CatchableError
    ## Raised if a runtime error occurred.
    token*: Token
      ## The `Token` is used to tell which line of code was running when the
      ## error occurred.

# Delayed imports
import ./expr

type
  Interpreter* = object
    ## Object that stores interpreter information
    globals*: Environment
    environment*: Environment
      ## Reference to the interpreter environment
    locals*: Table[Expr, int]

  LoxCallable* = ref object of Object
    ## An object for Lox calls.
    arity*: proc (caller: LoxCallable): int
      ## Procedure that returns the arity of the call.
    call*: proc (caller: LoxCallable, interpreter: var Interpreter,
                 arguments: seq[Object]): Object
      ## Procedure that evaluates the `LoxCallable` object and returns `Object`.
    toString*: proc (caller: LoxCallable): string
      ## Procedure that returns a `string` representation of the `LoxCallable`
      ## object

  LoxClass* = ref object of LoxCallable
    name*: string

  LoxInstance* = ref object of Object
    klass*: LoxClass
    fields*: Table[string, Object]

  Lox* = object
    ## Object that stores the Lox interpreter state
    interpreter*: Interpreter
      ## Interpreter information
    hadError* = false
      ## Determines if an error occurred in code execution.
    hadRuntimeError* = false
      ## Determines that a runtime error occurred while running a Lox script.
