import ./expr, ./token

type
  Stmt* = ref object of RootObj

  Block* = ref object of Stmt
    statements*: seq[Stmt]

  Expression* = ref object of Stmt
    expression*: Expr

  Print* = ref object of Stmt
    expression*: Expr

  Var* = ref object of Stmt
    name*: Token
    initializer*: Expr

proc newBlock*(statements: seq[Stmt]): Block =
  result = new(Block)
  result.statements = statements

proc newExpression*(expression: Expr): Expression =
  result = new(Expression)
  result.expression = expression

proc newPrint*(expression: Expr): Print =
  result = new(Print)
  result.expression = expression

proc newVar*(name: Token, initializer: Expr): Var =
  result = new(Var)
  result.name = name
  result.initializer = initializer

