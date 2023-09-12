# Stdlib imports
import std/[lists, sequtils, strformat]

# Internal imports
import ./expr, ./literals, ./logger, ./stmt, ./types

# Forward declaration
proc expression(lox: var Lox, parser: var Parser): Expr
proc declaration(lox: var Lox, parser: var Parser): Stmt
proc statement(lox: var Lox, parser: var Parser): Stmt

proc initParser*(tokens: seq[Token]): Parser =
  ## Initializes a `Parser` object with the sequence of `tokens`.
  result.tokens = tokens
  result.current = 0

proc previous(parser: Parser): Token =
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

proc error(lox: var Lox, token: Token, message: string): ref ParseError =
  ## Returns a `ParseError` object with the `message` message, as well as prints
  ## the token that caused the error with the `message` message.
  new(result)

  result.msg = message
  result.parent = nil

  logger.error(lox, token, message)

proc synchronize(parser: var Parser) =
  ## Discards tokens until it encounters a statement boundary. It is called
  ## after catching a `ParseError` to get the parser back in sync.
  discard advance(parser)

  while not isAtEnd(parser):
    if previous(parser).kind == Semicolon:
      break

    if peek(parser).kind in {TokenType.Class, Fun, Var, For, If, While, Print,
                             Return}:
      break

    discard advance(parser)

proc consume(lox: var Lox, parser: var Parser, typ: TokenType, message: string):
            Token =
  ## Checks if the next `Token` is of type `typ` and returns it consuming.
  ## Otherwise, it raises a `ParseError` error with the message `message`.
  if check(parser, typ):
    result = advance(parser)
  else:
    raise error(lox, peek(parser), message)

proc primary(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule primary.
  # primary → "true" | "false" | "nil"
  #         | NUMBER | STRING
  #         | "(" expression ")"
  #         | IDENTIFIER ;
  if match(parser, False):
    result = newLiteral(newBoolean(false))
  elif match(parser, True):
    result = newLiteral(newBoolean(true))
  elif match(parser, Nil):
    result = newLiteral(newObject())
  elif match(parser, TokenType.Number, TokenType.String):
    result = newLiteral(previous(parser).literal)
  elif match(parser, TokenType.This):
    result = newThis(previous(parser))
  elif match(parser, Identifier):
    result = newVariable(previous(parser))
  elif match(parser, LeftParen):
    result = expression(lox, parser)

    discard consume(lox, parser, RightParen, "Expect ')' after expression.")

    result = newGrouping(result)
  else:
    raise error(lox, peek(parser), "Expect expression.")

proc finishCall(lox: var Lox, parser: var Parser, callee: Expr): Expr =
  ## Helper procedure for parsing the call grammar rule.
  var arguments: seq[Expr]

  if not check(parser, RightParen):
    while true:
      if len(arguments) >= 255:
        logger.error(lox, peek(parser), "Can't have more than 255 arguments.")

      add(arguments, expression(lox, parser))

      if not match(parser, Comma):
        break

  let paren = consume(lox, parser, RightParen, "Expect ')' after arguments.")

  result = newCall(callee, paren, arguments)

proc call(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule call.
  # call → primary ( "(" arguments? ")" | "." IDENTIFIER )* ;
  result = primary(lox, parser)

  while true:
    if match(parser, LeftParen):
      result = finishCall(lox, parser, result)
    elif match(parser, Dot):
      let name = consume(lox, parser, Identifier,
                         "Expect property name after '.'.")

      result = newGet(result, name)
    else:
      break

proc unary(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule unary.
  # unary → ( "!" | "-" ) unary | call ;
  if match(parser, Bang, Minus):
    let
      operator = previous(parser)
      right = unary(lox, parser)

    result = newUnary(operator, right)
  else:
    result = call(lox, parser)

proc factor(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule factor.
  # factor → unary ( ( "/" | "*" ) unary )* ;
  result = unary(lox, parser)

  while match(parser, Slash, Star):
    let
      operator = previous(parser)
      right = unary(lox, parser)

    result = newBinary(result, operator, right)

proc term(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule term.
  # term → factor ( ( "-" | "+" ) factor )* ;
  result = factor(lox, parser)

  while match(parser, Minus, Plus):
    let
      operator = previous(parser)
      right = factor(lox, parser)

    result = newBinary(result, operator, right)

proc comparison(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule comparison.
  # comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  result = term(lox, parser)

  while match(parser, Greater, GreaterEqual, Less, LessEqual):
    let
      operator = previous(parser)
      right = term(lox, parser)

    result = newBinary(result, operator, right)

proc equality(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule equality.
  # equality → comparison ( ( "!=" | "==" ) comparison )* ;
  result = comparison(lox, parser)

  while match(parser, BangEqual, EqualEqual):
    let
      operator = previous(parser)
      right = comparison(lox, parser)

    result = newBinary(result, operator, right)

proc `and`(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule logic_and.
  # logic_and → equality ( "and" equality )* ;
  result = equality(lox, parser)

  while match(parser, And):
    let
      operator = previous(parser)
      right = equality(lox, parser)

    result = newLogical(result, operator, right)

proc `or`(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule logic_or.
  # logic_or → logic_and ( "or" logic_and )* ;
  result = `and`(lox, parser)

  while match(parser, Or):
    let
      operator = previous(parser)
      right = `and`(lox, parser)

    result = newLogical(result, operator, right)

proc assignment(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule assignment.
  # assignment → ( call "." )? IDENTIFIER "=" assignment
  #            | logic_or ;
  result = `or`(lox, parser)

  if match(parser, Equal):
    let
      equals = previous(parser)
      value = assignment(lox, parser)

    if result of Variable:
      let name = Variable(result).name

      result = newAssign(name, value)
    elif result of Get:
      let get = Get(result)

      result = newSet(get.obj, get.name, value)
    else:
      logger.error(lox, equals, "Invalid assignment target.")

proc expression(lox: var Lox, parser: var Parser): Expr =
  ## Returns `Expr` from parsing the grammar rule expression.
  # expression → assignment ;
  assignment(lox, parser)

proc printStatement(lox: var Lox, parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule printStmt.
  # printStmt → "print" expression ";" ;
  let value = expression(lox, parser)

  discard consume(lox, parser, Semicolon, "Expect ';' after value.")

  result = newPrint(value)

proc returnStatement(lox: var Lox, parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule returnStmt.
  # returnStmt → "return" expression? ";" ;
  let keyword = previous(parser)

  var value: Expr = nil

  if not check(parser, SemiColon):
    value = expression(lox, parser)

  discard consume(lox, parser, Semicolon, "Expect ';' after return value.")

  result = newReturn(keyword, value)

proc varDeclaration(lox: var Lox, parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule varDecl.
  # varDecl → "var" IDENTIFIER ( "=" expression )? ";" ;
  let name = consume(lox, parser, Identifier, "Expect variable name.")

  var initializer: Expr = nil

  if match(parser, Equal):
    initializer = expression(lox, parser)

  discard consume(lox, parser, Semicolon,
                  "Expect ';' after variable declaration.")

  result = newVar(name, initializer)

proc whileStatement(lox: var Lox, parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule whileStmt.
  # whileStmt → "while" "(" expression ")" statement ;
  discard consume(lox, parser, LeftParen, "Expect '(' after 'while'.")

  let condition = expression(lox, parser)

  discard consume(lox, parser, RightParen, "Expect ')' after condition.")

  let body = statement(lox, parser)

  result = newWhile(condition, body)

proc expressionStatement(lox: var Lox, parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule exprStmt.
  # exprStmt → expression ";" ;
  let expr = expression(lox, parser)

  discard consume(lox, parser, Semicolon, "Expect ';' after expression.")

  result = newExpression(expr)

proc `block`(lox: var Lox, parser: var Parser): seq[Stmt] =
  ## Returns `Stmt` from parsing the grammar rule block.
  # block → "{" declaration* "}" ;
  var statements = initSinglyLinkedList[Stmt]()

  while (not check(parser, RightBrace)) and (not isAtEnd(parser)):
    add(statements, declaration(lox, parser))

  discard consume(lox, parser, RightBrace, "Expect '}' after block.")

  result = toSeq(statements)

proc function(lox: var Lox, parser: var Parser, kind: string): Function =
  ## Returns `Function` from parsing the grammar rule funDecl.
  # funDecl  → "fun" function ;
  # function → IDENTIFIER "(" parameters? ")" block ;
  let name = consume(lox, parser, Identifier, fmt"Expect {kind} name.")

  discard consume(lox, parser, LeftParen, fmt"Expect '(' after {kind} name.")

  var parameters = newSeqOfCap[Token](255)

  if not check(parser, RightParen):
    while true:
      if len(parameters) >= 255:
        logger.error(lox, peek(parser), "Can't have more than 255 parameters.")

      add(parameters, consume(lox, parser, Identifier,
                              "Expect parameter name."))

      if not match(parser, Comma):
        break

  const leftBraceStr = '{'

  discard consume(lox, parser, RightParen, "Expect ')' after parameters.")
  discard consume(lox, parser, LeftBrace,
                  fmt"Expect '{leftBraceStr}' before {kind} body.")

  let body = `block`(lox, parser)

  result = newFunction(name, parameters, body)

proc ifStatement(lox: var Lox, parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule ifStmt.
  # ifStmt → "if" "(" expression ")" statement
  #        ( "else" statement )? ;
  discard consume(lox, parser, LeftParen, "Expect '(' after 'if'.")

  let condition = expression(lox, parser)

  discard consume(lox, parser, RightParen, "Expect ')' after if condition.")

  let thenBranch = statement(lox, parser)

  var elseBranch: Stmt = nil

  if match(parser, Else):
    elseBranch = statement(lox, parser)

  result = newIf(condition, thenBranch, elseBranch)

proc forStatement(lox: var Lox, parser: var Parser): Stmt =
  ## ## Returns `Stmt` from parsing the grammar rule forStmt.
  # forStmt → "for" "(" ( varDecl | exprStmt | ";" )
  #           expression? ";"
  #           expression? ")" statement ;
  discard consume(lox, parser, LeftParen, "Expect '(' after 'for'.")

  var initializer: Stmt

  if match(parser, Semicolon):
    initializer = nil
  elif match(parser, TokenType.Var):
    initializer = varDeclaration(lox, parser)
  else:
    initializer = expressionStatement(lox, parser)

  var condition: Expr = nil

  if not check(parser, Semicolon):
    condition = expression(lox, parser)

  discard consume(lox, parser, Semicolon, "Expect ';' after loop condition.")

  var increment: Expr = nil

  if not check(parser, RightParen):
    increment = expression(lox, parser)

  discard consume(lox, parser, RightParen, "Expect ')' after for clauses.")

  result = statement(lox, parser)

  if not isNil(increment):
    result = newBlock(@[result, newExpression(increment)])

  if isNil(condition):
    condition = newLiteral(newBoolean(true))

  result = newWhile(condition, result)

  if not isNil(initializer):
    result = newBlock(@[initializer, result])

proc statement(lox: var Lox, parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule statement.
  # statement → exprStmt
  #           | forStmt
  #           | ifStmt
  #           | printStmt
  #           | returnStmt
  #           | whileStmt
  #           | block ;
  if match(parser, For):
    result = forStatement(lox, parser)
  elif match(parser, TokenType.If):
    result = ifStatement(lox, parser)
  elif match(parser, TokenType.Print):
    result = printStatement(lox, parser)
  elif match(parser, TokenType.Return):
    result = returnStatement(lox, parser)
  elif match(parser, TokenType.While):
    result = whileStatement(lox, parser)
  elif match(parser, LeftBrace):
    result = newBlock(`block`(lox, parser))
  else:
    result = expressionStatement(lox, parser)

proc classDeclaration(lox: var Lox, parser: var Parser): Stmt =
  # classDecl → "class" IDENTIFIER "{" function* "}" ;
  let name = consume(lox, parser, Identifier, "Expect class name.")

  discard consume(lox, parser, LeftBrace, "Expect '{' before class body.")

  var methods: seq[Function]

  while not(check(parser, RightBrace)) and not(isAtEnd(parser)):
    add(methods, function(lox, parser, "method"))

  discard consume(lox, parser, RightBrace, "Expect '}' after class body.")

  result = newClass(name, methods)

proc declaration(lox: var Lox, parser: var Parser): Stmt =
  ## Returns `Stmt` from parsing the grammar rule declaration.
  # declaration → classDecl
  #             | funDecl
  #             | varDecl
  #             | statement ;
  try:
    if match(parser, TokenType.Class):
      result = classDeclaration(lox, parser)
    elif match(parser, Fun):
      result = function(lox, parser, "function")
    elif match(parser, TokenType.Var):
      result = varDeclaration(lox, parser)
    else:
      result = statement(lox, parser)
  except ParseError:
    synchronize(parser)

    result = nil

proc parse*(lox: var Lox, parser: var Parser): seq[Stmt] =
  ## Returns a sequence of parsed statements from `parser`.
  # program → declaration* EOF ;
  var statements = initSinglyLinkedList[Stmt]()

  while not isAtEnd(parser):
    add(statements, declaration(lox, parser))

  result = toSeq(statements)

when defined(nloxTests):
  proc parseForParseTest*(lox: var Lox, parser: var Parser): Expr =
    ## Returns a parsed `Expr` from `parser`.
    try:
      result = expression(lox, parser)
    except ParseError:
      result = nil
