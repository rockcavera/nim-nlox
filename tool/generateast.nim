import std/private/ospaths2, std/[cmdline, streams, strformat, strutils]

type
  FieldDescription = object
    name: string
    kind: string

  TypeDescription = object
    name: string
    fields: seq[FieldDescription]

proc splitFields(fields: string): seq[FieldDescription] =
  for field in split(fields, ','):
    let
      parts = splitWhitespace(field)
      name = parts[1]
      kind = parts[0]

    add(result, FieldDescription(name: name, kind: kind))

proc defineType(writer: FileStream, baseName: string, className: string, fieldList: seq[FieldDescription]) =
  writeLine(writer, indent(fmt"{className}* = ref object of {baseName}" , 2))

  for field in fieldList:
    writeLine(writer, indent(fmt"{field.name}*: {field.kind}" , 4))

proc defineConstructor(writer: FileStream, baseName: string, className: string, fieldList: seq[FieldDescription]) =
  writeLine(writer, fmt"proc new{className}(): {className} =")
  writeLine(writer, indent(fmt"new({className})", 2))

proc defineAst(outputDir: string, baseName: string, types: seq[string]) =
  let path = outputDir / fmt"{toLowerAscii(baseName)}.nim"

  var writer = newFileStream(path, fmWrite)

  if isNil(writer):
    quit(fmt"The file {path} cannot be opened.", 72)

  writeLine(writer, "# Stdlib imports")
  writeLine(writer, "import ./token")
  writeLine(writer, "")
  writeLine(writer, "type")
  writeLine(writer, indent(fmt"{baseName}* = ref object of RootObj" , 2))
  writeLine(writer, "")

  var allTypes: seq[TypeDescription]

  for kind in types:
    let
      parts = split(kind, ':')
      name = strip(parts[0])
      fields = splitFields(strip(parts[1]))

    add(allTypes, TypeDescription(name: name, fields: fields))

  # Defining the types
  for kind in allTypes:
    defineType(writer, baseName, kind.name, kind.fields)

    writeLine(writer, "")

  # Defining the constructors
  for kind in allTypes:
    defineConstructor(writer, baseName, kind.name, kind.fields)

    writeLine(writer, "")

  close(writer)

proc main*(args: seq[string]) =
  if len(args) != 1:
    quit("Usage: generate_ast <output directory>", 64)

  let outputDir = args[0]

  defineAst(outputDir, "Expr", @[
    "Binary   : Expr left, Token operator, Expr right",
    "Grouping : Expr expression",
    "Literal  : Object value",
    "Unary    : Token operator, Expr right"])

main(commandLineParams())
