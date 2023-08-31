import ./expr

type
  Stmt* = ref object of RootObj

  Expression* = ref object of Stmt
    expression*: Expr

  Print* = ref object of Stmt
    expression*: Expr

proc newExpression*(expression: Expr): Expression =
  result = new(Expression)
  result.expression = expression

proc newPrint*(expression: Expr): Print =
  result = new(Print)
  result.expression = expression

