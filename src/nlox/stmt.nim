import ./expr, ./types

type
  Stmt* = ref object of RootObj

  Block* = ref object of Stmt
    statements*: seq[Stmt]

  Expression* = ref object of Stmt
    expression*: Expr

  If* = ref object of Stmt
    condition*: Expr
    thenBranch*: Stmt
    elseBranch*: Stmt

  Print* = ref object of Stmt
    expression*: Expr

  Var* = ref object of Stmt
    name*: Token
    initializer*: Expr

  While* = ref object of Stmt
    condition*: Expr
    body*: Stmt

proc newBlock*(statements: seq[Stmt]): Block =
  result = new(Block)
  result.statements = statements

proc newExpression*(expression: Expr): Expression =
  result = new(Expression)
  result.expression = expression

proc newIf*(condition: Expr, thenBranch: Stmt, elseBranch: Stmt): If =
  result = new(If)
  result.condition = condition
  result.thenBranch = thenBranch
  result.elseBranch = elseBranch

proc newPrint*(expression: Expr): Print =
  result = new(Print)
  result.expression = expression

proc newVar*(name: Token, initializer: Expr): Var =
  result = new(Var)
  result.name = name
  result.initializer = initializer

proc newWhile*(condition: Expr, body: Stmt): While =
  result = new(While)
  result.condition = condition
  result.body = body

