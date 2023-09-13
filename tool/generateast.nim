import std/private/[oscommon, ospaths2], std/[cmdline, streams, strformat, strutils]

type
  FieldDescription = object
    name: string
    kind: string

  TypeDescription = object
    name: string
    fields: seq[FieldDescription]

const findComment = "# <Put it below, generateast!> #"

proc truncateFile(fileName: string): FileStream =
  if not fileExists(fileName):
    quit(fmt"The file `{fileName}` does not exist!", 72)

  var data = readFile(fileName)

  let i = find(data, findComment)

  if i == -1:
    quit(fmt"Could not find comment `{findComment}` in `{fileName}`", 70)

  setLen(data, len(findComment) + i)

  result = newFileStream(fileName, fmWrite)

  if isNil(result):
    quit(fmt"The file `{fileName}` cannot be opened.", 72)

  write(result, data)

  writeLine(result, "")
  writeLine(result, "")

proc splitFields(fields: string): seq[FieldDescription] =
  for field in split(fields, ','):
    let
      parts = splitWhitespace(field)
      name = parts[1]
      kind = parts[0]

    add(result, FieldDescription(name: name, kind: kind))

proc defineType(writer: FileStream, baseName: string, kind: TypeDescription) =
  writeLine(writer, indent(fmt"{kind.name}* = ref object of {baseName}" , 2))

  for field in kind.fields:
    writeLine(writer, indent(fmt"{field.name}*: {field.kind}" , 4))

proc fieldsToParamStr(fields: seq[FieldDescription]): string =
  if len(fields) > 0:
    for field in fields:
      add(result, fmt"{field.name}: {field.kind}, ")

    setLen(result, len(result) - 2)

proc defineConstructor(writer: FileStream, kind: TypeDescription) =
  writeLine(writer, fmt"proc new{kind.name}*({fieldsToParamStr(kind.fields)}): {kind.name} =")
  writeLine(writer, indent(fmt"result = new({kind.name})", 2))

  for field in kind.fields:
    writeLine(writer, indent(fmt"result.{field.name} = {field.name}", 2))

proc defineAst(typesFS, initializersFS: FileStream, baseName: string, types: seq[string]) =
  writeLine(typesFS, indent(fmt"# From {toLower(baseName)}" , 2))
  writeLine(typesFS, "")
  writeLine(typesFS, indent(fmt"{baseName}* = ref object of RootObj" , 2))
  writeLine(typesFS, "")

  var allTypes: seq[TypeDescription]

  for kind in types:
    let
      parts = split(kind, ':')
      name = strip(parts[0])
      fields = splitFields(strip(parts[1]))

    add(allTypes, TypeDescription(name: name, fields: fields))

  # Defining the types
  for kind in allTypes:
    defineType(typesFS, baseName, kind)

    writeLine(typesFS, "")

  writeLine(typesFS, indent(fmt"# End {toLower(baseName)}" , 2))
  writeLine(typesFS, "")

  # Defining the constructors
  writeLine(initializersFS, indent(fmt"# From {toLower(baseName)}" , 2))
  writeLine(initializersFS, "")

  for kind in allTypes:
    defineConstructor(initializersFS, kind)

    writeLine(initializersFS, "")

  writeLine(initializersFS, indent(fmt"# End {toLower(baseName)}" , 2))
  writeLine(initializersFS, "")

proc main*(args: seq[string]) =
  if len(args) != 1:
    quit("Usage: generate_ast <output directory>", 64)

  let
    outputDir = args[0]
    typesFile = outputDir / "types.nim"
    initializersFile = outputDir / "initializers.nim"

  var
    typesFS = truncateFile(typesFile)
    initializersFS = truncateFile(initializersFile)

  defineAst(typesFS, initializersFS, "Expr", @[
    "Assign   : Token name, Expr value",
    "Binary   : Expr left, Token operator, Expr right",
    "Call     : Expr callee, Token paren, seq[Expr] arguments",
    "Get      : Expr obj, Token name",
    "Grouping : Expr expression",
    "Literal  : Object value",
    "Logical  : Expr left, Token operator, Expr right",
    "Set      : Expr obj, Token name, Expr value",
    "Super    : Token keyword, Token `method`",
    "This     : Token keyword",
    "Unary    : Token operator, Expr right",
    "Variable : Token name"])

  defineAst(typesFS, initializersFS, "Stmt", @[
    "Block      : seq[Stmt] statements",
    "Class      : Token name, Variable superclass," &
                " seq[Function] methods",
    "Expression : Expr expression",
    "Function   : Token name, seq[Token] params," &
                " seq[Stmt] body",
    "If         : Expr condition, Stmt thenBranch," &
                " Stmt elseBranch",
    "Print      : Expr expression",
    "Return     : Token keyword, Expr value",
    "Var        : Token name, Expr initializer",
    "While      : Expr condition, Stmt body"])

  close(typesFS)
  close(initializersFS)

main(commandLineParams())
