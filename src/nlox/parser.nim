import ./expr, ./logger, ./token, ./tokentype

type
  Parser = object
    tokens: seq[Token]
    current: int

  ParseError = object of CatchableError

# Forward declaration
proc expression(parser: var Parser): Expr

proc initParser*(tokens: seq[Token]): Parser =
  result.tokens = tokens
  result.current = 0

proc previous(parser: var Parser): Token =
  parser.tokens[parser.current - 1]

proc peek(parser: Parser): Token =
  parser.tokens[parser.current]

proc isAtEnd(parser: Parser): bool =
  peek(parser).kind == Eof

proc advance(parser: var Parser): Token =
  if not isAtEnd(parser):
    inc(parser.current)

  result = previous(parser)

proc check(parser: Parser, typ: TokenType): bool =
  if isAtEnd(parser):
    result = false
  else:
    result = peek(parser).kind == typ

proc match(parser: var Parser, types: varargs[TokenType]): bool =
  result = false

  for typ in types:
    if check(parser, typ):
      discard advance(parser)

      result = true

      break

proc error(token: Token, message: string): ref ParseError =
  new(result)

  result.msg = message
  result.parent = nil

  logger.error(token, message)

proc synchronize(parser: var Parser) =
  discard advance(parser)

  while not isAtEnd(parser):
    if previous(parser).kind == Semicolon:
      break

    if peek(parser).kind in {Class, Fun, Var, For, If, While, Print, Return}:
      break

    discard advance(parser)

proc consume(parser: var Parser, typ: TokenType, message: string): Token =
  if check(parser, typ):
    result = advance(parser)
  else:
    raise error(peek(parser), message) # raise

proc primary(parser: var Parser): Expr =
  if match(parser, False):
    result = newLiteral(LiteralValue(kind: LitBoolean, booleanLit: false))
  elif match(parser, True):
    result = newLiteral(LiteralValue(kind: LitBoolean, booleanLit: true))
  elif match(parser, Nil):
    result = newLiteral(LiteralValue(kind: LitNull))
  elif match(parser, Number, String):
    result = newLiteral(previous(parser).literal)
  elif match(parser, LeftParen):
    result = expression(parser)

    discard consume(parser, RightParen, "Expect ')' after expression.")

    result = newGrouping(result)

proc unary(parser: var Parser): Expr =
  if match(parser, Bang, Minus):
    let
      operator = previous(parser)
      right = unary(parser)

    result = newUnary(operator, right)
  else:
    result = primary(parser)

proc factor(parser: var Parser): Expr =
  result = unary(parser)

  while match(parser, Slash, Star):
    let
      operator = previous(parser)
      right = unary(parser)

    result = newBinary(result, operator, right)

proc term(parser: var Parser): Expr =
  result = factor(parser)

  while match(parser, Minus, Plus):
    let
      operator = previous(parser)
      right = factor(parser)

    result = newBinary(result, operator, right)

proc comparison(parser: var Parser): Expr =
  result = term(parser)

  while match(parser, Greater, GreaterEqual, Less, LessEqual):
    let
      operator = previous(parser)
      right = term(parser)

    result = newBinary(result, operator, right)

proc equality(parser: var Parser): Expr =
  result = comparison(parser)

  while match(parser, BangEqual, EqualEqual):
    let
      operator = previous(parser)
      right = comparison(parser)

    result = newBinary(result, operator, right)

proc expression(parser: var Parser): Expr =
  equality(parser)
