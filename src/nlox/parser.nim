# Stdlib imports
import std/[lists, sequtils]

# Internal imports
import ./expr, ./literals, ./logger, ./stmt, ./token, ./tokentype

type
  Parser* = object
    ## Object that stores parser information.
    tokens: seq[Token]
      ## Sequence of tokens.
    current: int
      ## Index of next token waiting for parsing.

  ParseError = object of CatchableError
    ## Raised if a parsing error occurred.

# Forward declaration
proc expression(parser: var Parser): Expr
proc declaration(parser: var Parser): Stmt
proc statement(parser: var Parser): Stmt

proc initParser*(tokens: seq[Token]): Parser =
  ## Initializes a `Parser` object with the sequence of `tokens`.
  result.tokens = tokens
  result.current = 0

proc previous(parser: var Parser): Token =
  ## Returns the last `Token`.
  parser.tokens[parser.current - 1]

proc peek(parser: Parser): Token =
  ## Returns the next `Token`.
  parser.tokens[parser.current]

proc isAtEnd(parser: Parser): bool =
  ## Returns `true` if the next token is of type `Eof`, that is, if there are no
  ## more tokens to parse. Otherwise, it returns `false`.
  peek(parser).kind == Eof

proc advance(parser: var Parser): Token =
  ## Consumes the current `Token` and returns it.
  if not isAtEnd(parser):
    inc(parser.current)

  result = previous(parser)

proc check(parser: Parser, typ: TokenType): bool =
  ## Checks if the next token is of type `typ` and returns `true`. Otherwise, it
  ## returns `false`.
  if isAtEnd(parser):
    result = false
  else:
    result = peek(parser).kind == typ

proc match(parser: var Parser, types: varargs[TokenType]): bool =
  ## Returns `true` if the next token matches any of the token types in the
  ## `types` list and consumes it. Otherwise, it returns `false` and does not
  ## consume it.
  result = false

  for typ in types:
    if check(parser, typ):
      discard advance(parser)

      result = true

      break

proc error(token: Token, message: string): ref ParseError =
  ## Returns a `ParseError` object with the `message` message, as well as prints
  ## the token that caused the error with the `message` message.
  new(result)

  result.msg = message
  result.parent = nil

  logger.error(token, message)

proc synchronize(parser: var Parser) =
  ## Discards tokens until it encounters a statement boundary. It is called
  ## after catching a `ParseError` to get the parser back in sync.
  discard advance(parser)

  while not isAtEnd(parser):
    if previous(parser).kind == Semicolon:
      break

    if peek(parser).kind in {Class, Fun, Var, For, If, While, Print, Return}:
      break

    discard advance(parser)

proc consume(parser: var Parser, typ: TokenType, message: string): Token =
  ## Checks if the next `Token` is of type `typ` and returns it consuming.
  ## Otherwise, it raises a `ParseError` error with the message `message`.
  if check(parser, typ):
    result = advance(parser)
  else:
    raise error(peek(parser), message)

proc primary(parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule primary.
  # primary → "true" | "false" | "nil"
  #         | NUMBER | STRING
  #         | "(" expression ")"
  #         | IDENTIFIER ;
  if match(parser, False):
    result = newLiteral(initLiteralBoolean(false))
  elif match(parser, True):
    result = newLiteral(initLiteralBoolean(true))
  elif match(parser, Nil):
    result = newLiteral(initLiteral())
  elif match(parser, Number, String):
    result = newLiteral(previous(parser).literal)
  elif match(parser, Identifier):
    result = newVariable(previous(parser))
  elif match(parser, LeftParen):
    result = expression(parser)

    discard consume(parser, RightParen, "Expect ')' after expression.")

    result = newGrouping(result)
  else:
    raise error(peek(parser), "Expect expression.")

proc unary(parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule unary.
  # unary → ( "!" | "-" ) unary
  #       | primary ;
  if match(parser, Bang, Minus):
    let
      operator = previous(parser)
      right = unary(parser)

    result = newUnary(operator, right)
  else:
    result = primary(parser)

proc factor(parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule factor.
  # factor → unary ( ( "/" | "*" ) unary )* ;
  result = unary(parser)

  while match(parser, Slash, Star):
    let
      operator = previous(parser)
      right = unary(parser)

    result = newBinary(result, operator, right)

proc term(parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule term.
  # term → factor ( ( "-" | "+" ) factor )* ;
  result = factor(parser)

  while match(parser, Minus, Plus):
    let
      operator = previous(parser)
      right = factor(parser)

    result = newBinary(result, operator, right)

proc comparison(parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule comparison.
  # comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  result = term(parser)

  while match(parser, Greater, GreaterEqual, Less, LessEqual):
    let
      operator = previous(parser)
      right = term(parser)

    result = newBinary(result, operator, right)

proc equality(parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule equality.
  # equality → comparison ( ( "!=" | "==" ) comparison )* ;
  result = comparison(parser)

  while match(parser, BangEqual, EqualEqual):
    let
      operator = previous(parser)
      right = comparison(parser)

    result = newBinary(result, operator, right)

proc assignment(parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule assignment.
  # assignment → IDENTIFIER "=" assignment
  #            | equality ;
  result = equality(parser)

  if match(parser, Equal):
    let
      equals = previous(parser)
      value = assignment(parser)

    if result of Variable:
      let name = Variable(result).name

      result = newAssign(name, value)
    else:
      logger.error(equals, "Invalid assignment target.")

proc expression(parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule expression.
  # expression → assignment ;
  assignment(parser)

proc printStatement(parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule printStmt.
  # printStmt → "print" expression ";" ;
  let value = expression(parser)

  discard consume(parser, Semicolon, "Expect ';' after value.")

  result = newPrint(value)

proc varDeclaration(parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule varDecl.
  # varDecl → "var" IDENTIFIER ( "=" expression )? ";" ;
  let name = consume(parser, Identifier, "Expect variable name.")

  var initializer: Expr = nil

  if match(parser, Equal):
    initializer = expression(parser)

  discard consume(parser, Semicolon, "Expect ';' after variable declaration.")

  result = newVar(name, initializer)

proc expressionStatement(parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule exprStmt.
  # exprStmt → expression ";" ;
  let expr = expression(parser)

  discard consume(parser, Semicolon, "Expect ';' after expression.")

  result = newExpression(expr)

proc block2(parser: var Parser): seq[Stmt] =
  ## Returns `Stmt` from parsing the grammar rule block.
  # block → "{" declaration* "}" ;
  var statements = initSinglyLinkedList[Stmt]()

  while (not check(parser, RightBrace)) and (not isAtEnd(parser)):
    add(statements, declaration(parser))

  discard consume(parser, RightBrace, "Expect '}' after block.")

  result = toSeq(statements)

proc ifStatement(parser: var Parser): Stmt =
  discard consume(parser, LeftParen, "Expect '(' after 'if'.")

  let condition = expression(parser)

  discard consume(parser, RightParen, "Expect ')' after if condition.")

  let thenBranch = statement(parser)

  var elseBranch: Stmt = nil

  if match(parser, Else):
    elseBranch = statement(parser)

  result = newIf(condition, thenBranch, elseBranch)

proc statement(parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule statement.
  # statement → exprStmt
  #           | ifStmt
  #           | printStmt
  #           | block ;
  if match(parser, tokentype.If):
    result = ifStatement(parser)
  elif match(parser, tokentype.Print):
    result = printStatement(parser)
  elif match(parser, LeftBrace):
    result = newBlock(block2(parser)) # `block` is a reserved keyword in Nim.
  else:
    result = expressionStatement(parser)

proc declaration(parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule declaration.
  # declaration → varDecl
  #             | statement ;
  try:
    if match(parser, tokentype.Var):
      result = varDeclaration(parser)
    else:
      result = statement(parser)
  except ParseError:
    synchronize(parser)

    result = nil

proc parse*(parser: var Parser): seq[Stmt] =
  ## Returns a sequence of parsed statements from `parser`.
  # program → declaration* EOF ;
  var statements = initSinglyLinkedList[Stmt]()

  while not isAtEnd(parser):
    add(statements, declaration(parser))

  result = toSeq(statements)

when defined(nloxTests):
  proc parseForParseTest*(parser: var Parser): Expr =
    ## Returns a parsed `Expr` from `parser`.
    try:
      result = expression(parser)
    except ParseError:
      result = nil
