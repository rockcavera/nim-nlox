import ./literals, ./token

type
  Expr* = ref object of RootObj

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

  Grouping* = ref object of Expr
    expression*: Expr

  Literal* = ref object of Expr
    value*: LiteralValue

  Logical* = ref object of Expr
    left*: Expr
    operator*: Token
    right*: Expr

  Unary* = ref object of Expr
    operator*: Token
    right*: Expr

  Variable* = ref object of Expr
    name*: Token

proc newAssign*(name: Token, value: Expr): Assign =
  result = new(Assign)
  result.name = name
  result.value = value

proc newBinary*(left: Expr, operator: Token, right: Expr): Binary =
  result = new(Binary)
  result.left = left
  result.operator = operator
  result.right = right

proc newCall*(callee: Expr, paren: Token, arguments: seq[Expr]): Call =
  result = new(Call)
  result.callee = callee
  result.paren = paren
  result.arguments = arguments

proc newGrouping*(expression: Expr): Grouping =
  result = new(Grouping)
  result.expression = expression

proc newLiteral*(value: LiteralValue): Literal =
  result = new(Literal)
  result.value = value

proc newLogical*(left: Expr, operator: Token, right: Expr): Logical =
  result = new(Logical)
  result.left = left
  result.operator = operator
  result.right = right

proc newUnary*(operator: Token, right: Expr): Unary =
  result = new(Unary)
  result.operator = operator
  result.right = right

proc newVariable*(name: Token): Variable =
  result = new(Variable)
  result.name = name

