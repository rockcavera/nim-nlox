# Stdlib imports
import std/[hashes, lists, tables]

type
  Object* = ref object of RootObj
    ## Base object.

  Boolean* = ref object of Object
    ## An object for Lox's Boolean type.
    data*: bool

  Number* = ref object of Object
    ## An object for Lox's Number type.
    data*: float

  String* = ref object of Object
    ## An object for Lox's String type.
    data*: string
    hash*: Hash

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
    lexeme*: String
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
    keywords*: Table[string, TokenType]
      ## A table with all keywords.

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
    values*: TableRef[String, Object]
      ## Hash table that stores variable names and values.

  ParseError* = object of CatchableError
    ## Raised if a parsing error occurred.

  RuntimeError* = ref object of CatchableError
    ## Raised if a runtime error occurred.
    token*: Token
      ## The `Token` is used to tell which line of code was running when the
      ## error occurred.

  Interpreter* = object
    ## Object that stores interpreter information
    globals*: Environment
      ## Environment with global variables.
    environment*: Environment
      ## Reference to the interpreter environment
    locals*: Table[Expr, int]
      ## Table that stores the scope distances between the variable `Expr` and
      ## the location where it is defined.

  LoxCallable* = ref object of Object
    ## An object for Lox calls.
    arity*: proc (caller: LoxCallable): int {.nimcall.}
      ## Procedure that returns the arity of the call.
    call*: proc (caller: LoxCallable, interpreter: var Interpreter,
                 arguments: seq[Object]): Object {.nimcall.}
      ## Procedure that evaluates the `LoxCallable` object and returns `Object`.
    toString*: proc (caller: LoxCallable): string {.nimcall.}
      ## Procedure that returns a `string` representation of the `LoxCallable`
      ## object

  LoxFunction* = ref object of LoxCallable
    ## Object that stores Lox function information.
    declaration*: Function
      ## Lox function declarations.
    closure*: Environment
      ## Stores the function's current environment.
    isInitializer*: bool
      ## Stores whether `LoxFunction` is an initializer.

  LoxClass* = ref object of LoxCallable
    ## Object that stores Lox class information.
    name*: String
      ## Lox class name.
    superclass*: LoxClass
      ## Superclass of `LoxClass`
    methods*: TableRef[String, LoxFunction]
      ## Lox class methods.

  LoxInstance* = ref object of Object
    ## Object that stores Lox instance information.
    klass*: LoxClass
      ## Lox class bound to instance.
    fields*: TableRef[String, Object]
      ## Lox instance fields.

  Lox* = object
    ## Object that stores the Lox interpreter state
    interpreter*: Interpreter
      ## Interpreter information
    hadError* = false
      ## Determines if an error occurred in code execution.
    hadRuntimeError* = false
      ## Determines that a runtime error occurred while running a Lox script.

  # <Put it below, generateast!> #

  # From expr

  Expr* = ref object of RootObj
    hash*: Hash

  Assign* = ref object of Expr
    name*: Token
    value*: Expr

  Binary* = ref object of Expr
    left*: Expr
    operator*: Token
    right*: Expr

  Call* = ref object of Expr
    callee*: Expr
    paren*: Token
    arguments*: seq[Expr]

  Get* = ref object of Expr
    obj*: Expr
    name*: Token

  Grouping* = ref object of Expr
    expression*: Expr

  Literal* = ref object of Expr
    value*: Object

  Logical* = ref object of Expr
    left*: Expr
    operator*: Token
    right*: Expr

  Set* = ref object of Expr
    obj*: Expr
    name*: Token
    value*: Expr

  Super* = ref object of Expr
    keyword*: Token
    `method`*: Token

  This* = ref object of Expr
    keyword*: Token

  Unary* = ref object of Expr
    operator*: Token
    right*: Expr

  Variable* = ref object of Expr
    name*: Token

  # End expr

  # From stmt

  Stmt* = ref object of RootObj

  Block* = ref object of Stmt
    statements*: seq[Stmt]

  Class* = ref object of Stmt
    name*: Token
    superclass*: Variable
    methods*: seq[Function]

  Expression* = ref object of Stmt
    expression*: Expr

  Function* = ref object of Stmt
    name*: Token
    params*: seq[Token]
    body*: seq[Stmt]

  If* = ref object of Stmt
    condition*: Expr
    thenBranch*: Stmt
    elseBranch*: Stmt

  Print* = ref object of Stmt
    expression*: Expr

  Return* = ref object of Stmt
    keyword*: Token
    value*: Expr

  Var* = ref object of Stmt
    name*: Token
    initializer*: Expr

  While* = ref object of Stmt
    condition*: Expr
    body*: Stmt

  # End stmt
