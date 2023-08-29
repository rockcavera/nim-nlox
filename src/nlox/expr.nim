# Stdlib imports
import ./token

type
  Expr* = ref object of RootObj

  Binary* = ref object of Expr
    left*: Expr
    operator*: Token
    right*: Expr

  Grouping* = ref object of Expr
    expression*: Expr

  Literal* = ref object of Expr
    value*: LiteralValue

  Unary* = ref object of Expr
    operator*: Token
    right*: Expr

proc newBinary*(left: Expr, operator: Token, right: Expr): Binary =
  result = new(Binary)
  result.left = left
  result.operator = operator
  result.right = right

proc newGrouping*(expression: Expr): Grouping =
  result = new(Grouping)
  result.expression = expression

proc newLiteral*(value: LiteralValue): Literal =
  result = new(Literal)
  result.value = value

proc newUnary*(operator: Token, right: Expr): Unary =
  result = new(Unary)
  result.operator = operator
  result.right = right

