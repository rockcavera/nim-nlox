# Stdlib imports
import std/tables

# Internal imports
import ./types

# From loxclass

proc newLoxClass*(name: string, superclass: LoxClass,
                  methods: Table[string, LoxFunction]): LoxClass =
  ## Creates and returns a `LoxClass` with the name `name` and the methods
  ## `methods`.
  result = new(LoxClass)
  result.name = name
  result.superclass = superclass
  result.methods = methods

# End loxclass

# From loxinstance

proc newLoxInstance*(klass: LoxClass): LoxInstance =
  ## Creates and returns a `LoxInstance` with `klass`.
  result = new(LoxInstance)
  result.klass = klass

# End loxinstance

# From loxfunction

proc newLoxFunction*(declaration: Function, closure: Environment,
                     isInitializer: bool): LoxFunction =
  ## Create a `LoxFunction` with `declaration` and the current environment
  ## `closure`. If the `isInitializer` parameter is `true`, it informs that the
  ## `LoxFunction` is an initializer.
  result = new(LoxFunction)
  result.declaration = declaration
  result.closure = closure
  result.isInitializer = isInitializer

# End loxfunction

# <Put it below, generateast!> #

  # From expr

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

proc newGet*(obj: Expr, name: Token): Get =
  result = new(Get)
  result.obj = obj
  result.name = name

proc newGrouping*(expression: Expr): Grouping =
  result = new(Grouping)
  result.expression = expression

proc newLiteral*(value: Object): Literal =
  result = new(Literal)
  result.value = value

proc newLogical*(left: Expr, operator: Token, right: Expr): Logical =
  result = new(Logical)
  result.left = left
  result.operator = operator
  result.right = right

proc newSet*(obj: Expr, name: Token, value: Expr): Set =
  result = new(Set)
  result.obj = obj
  result.name = name
  result.value = value

proc newSuper*(keyword: Token, `method`: Token): Super =
  result = new(Super)
  result.keyword = keyword
  result.`method` = `method`

proc newThis*(keyword: Token): This =
  result = new(This)
  result.keyword = keyword

proc newUnary*(operator: Token, right: Expr): Unary =
  result = new(Unary)
  result.operator = operator
  result.right = right

proc newVariable*(name: Token): Variable =
  result = new(Variable)
  result.name = name

  # End expr

  # From stmt

proc newBlock*(statements: seq[Stmt]): Block =
  result = new(Block)
  result.statements = statements

proc newClass*(name: Token, superclass: Variable, methods: seq[Function]): Class =
  result = new(Class)
  result.name = name
  result.superclass = superclass
  result.methods = methods

proc newExpression*(expression: Expr): Expression =
  result = new(Expression)
  result.expression = expression

proc newFunction*(name: Token, params: seq[Token], body: seq[Stmt]): Function =
  result = new(Function)
  result.name = name
  result.params = params
  result.body = body

proc newIf*(condition: Expr, thenBranch: Stmt, elseBranch: Stmt): If =
  result = new(If)
  result.condition = condition
  result.thenBranch = thenBranch
  result.elseBranch = elseBranch

proc newPrint*(expression: Expr): Print =
  result = new(Print)
  result.expression = expression

proc newReturn*(keyword: Token, value: Expr): Return =
  result = new(Return)
  result.keyword = keyword
  result.value = value

proc newVar*(name: Token, initializer: Expr): Var =
  result = new(Var)
  result.name = name
  result.initializer = initializer

proc newWhile*(condition: Expr, body: Stmt): While =
  result = new(While)
  result.condition = condition
  result.body = body

  # End stmt

