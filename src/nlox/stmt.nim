# Internal imports
import ./types

proc newBlock*(statements: seq[Stmt]): Block =
  Block(statements: statements)

proc newClass*(name: Token, superclass: Variable, methods: seq[Function]): Class =
  Class(name: name,superclass: superclass,methods: methods)

proc newExpression*(expression: Expr): Expression =
  Expression(expression: expression)

proc newFunction*(name: Token, params: seq[Token], body: seq[Stmt]): Function =
  Function(name: name,params: params,body: body)

proc newIf*(condition: Expr, thenBranch: Stmt, elseBranch: Stmt): If =
  If(condition: condition,thenBranch: thenBranch,elseBranch: elseBranch)

proc newPrint*(expression: Expr): Print =
  Print(expression: expression)

proc newReturn*(keyword: Token, value: Expr): Return =
  Return(keyword: keyword,value: value)

proc newVar*(name: Token, initializer: Expr): Var =
  Var(name: name,initializer: initializer)

proc newWhile*(condition: Expr, body: Stmt): While =
  While(condition: condition,body: body)

