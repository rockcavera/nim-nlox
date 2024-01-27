when not defined(linux):
  {.fatal: "Valgrind only Linux".}

import std/[exitprocs, osproc, random, streams, strutils, strformat, unittest],
       std/private/[oscommon, osfiles, ospaths2]

randomize()

const
  nloxSource = "src" / "nlox.nim"
  loxScriptsFolder* = "tests" / "scripts"
  valgrindTemplate = "valgrind --leak-check=full $1 $2" # <NLOXEXE> <SCRIPTLOX>
  valgrindLeakTemplate = "$1LEAK SUMMARY:" # <VALGRIND_ID>

let nloxExeName = "nlox" & $rand(100_000..999_999)

when defined(windows):
  let nloxExe = nloxExeName & ".exe"
else:
  let nloxExe = getCurrentDir() / nloxExeName

var nloxExeCompiled = false

proc removeNloxExe() =
  if fileExists(nloxExe):
    discard tryRemoveFile(nloxExe)

proc compilenlox() =
  if (not fileExists(nloxExe)) or (not nloxExeCompiled):
    if not dirExists("src"):
      quit("`src` folder not found.", 72)

    if not fileExists(nloxSource):
      quit(fmt"`{nloxSource}` file not found.", 72)

    let cmdLine = fmt"nim c -o:{nloxExeName} --mm:arc --panics:on -d:useMalloc --debugger:native --threads:off {nloxSource}"

    echo "  ", cmdLine

    let (_, exitCode) = execCmdEx(cmdLine)

    if (exitCode != 0) or (not fileExists(nloxExe)):
      quit(fmt"Unable to compile `{nloxSource}`.", 70)

    nloxExeCompiled = true

    addExitProc(removeNloxExe)

proc getIdValgrind(s: string): string =
  var i = 0

  while s[i] == '=':
    add(result, '=')

    inc(i)

  while s[i] != '=':
    add(result, s[i])

    inc(i)

  while s[i] == '=':
    add(result, '=')

    inc(i)

  add(result, ' ')

proc nloxTestLeak(script: string): tuple[leak: bool, output: string, exitCode: int] =
  compilenlox()

  let scriptFull = loxScriptsFolder / script

  let (rawOutput, exitcode) = execCmdEx(valgrindTemplate % [nloxExe, scriptFull])

  result.exitCode = exitcode

  let
    valgrindId = getIdValgrind(rawOutput)
    strLeaked = valgrindLeakTemplate % valgrindId

  var
    ss = newStringStream(rawOutput)
    line: string
    recOutput = false

  while readLine(ss, line):
    if line == valgrindId:
      recOutput = not recOutput
    elif line == strLeaked:
      result.leak = true

      break
    elif not(startsWith(line, valgrindId)) and recOutput:
      add(result.output, line)
      add(result.output, '\L')

  close(ss)

template checkLeak() =
  let (leak, output, exitcode) = nloxTestLeak(script)

  #echo (leak, output, exitcode)
  check leak == false
  check (output, exitcode) == (expectedOutput, expectedExitCode)

proc isValgrindPresent(): bool =
  let (_, exitcode) = execCmdEx("valgrind --version")

  if exitcode == 0:
    result = true

if not isValgrindPresent():
  quit("Valgrind could not be found", 1)

suite "Assignment":
  const folder = "assignment"

  test "Associativity":
    const
      script = folder / "associativity.lox"
      expectedExitCode = 0
      expectedOutput = """c
c
c
"""

    checkLeak()

  test "Global":
    const
      script = folder / "global.lox"
      expectedExitCode = 0
      expectedOutput = """before
after
arg
arg
"""

    checkLeak()

  test "Grouping":
    const
      script = folder / "grouping.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at '=': Invalid assignment target.
"""

    checkLeak()

  test "Infix Operator":
    const
      script = folder / "infix_operator.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at '=': Invalid assignment target.
"""

    checkLeak()

  test "Local":
    const
      script = folder / "local.lox"
      expectedExitCode = 0
      expectedOutput = """before
after
arg
arg
"""

    checkLeak()

  test "Prefix Operator":
    const
      script = folder / "prefix_operator.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at '=': Invalid assignment target.
"""

    checkLeak()

  test "Syntax":
    const
      script = folder / "syntax.lox"
      expectedExitCode = 0
      expectedOutput = """var
var
"""

    checkLeak()

  test "Undefined":
    const
      script = folder / "undefined.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'unknown'.
[line 1]
"""

    checkLeak()

  test "To this":
    const
      script = folder / "to_this.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at '=': Invalid assignment target.
"""

    checkLeak()

suite "Block":
  const folder = "block"

  test "Scope":
    const
      script = folder / "scope.lox"
      expectedExitCode = 0
      expectedOutput = """inner
outer
"""

    checkLeak()

  test "Empty":
    const
      script = folder / "empty.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

suite "Bool":
  const folder = "bool"

  test "Equality":
    const
      script = folder / "equality.lox"
      expectedExitCode = 0
      expectedOutput = """true
false
false
true
false
false
false
false
false
false
true
true
false
true
true
true
true
true
"""

    checkLeak()

  test "Not":
    const
      script = folder / "not.lox"
      expectedExitCode = 0
      expectedOutput = """false
true
true
"""

    checkLeak()

suite "Call":
  const folder = "call"

  test "Bool":
    const
      script = folder / "bool.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 1]
"""

    checkLeak()

  test "Nil":
    const
      script = folder / "nil.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 1]
"""

    checkLeak()

  test "Num":
    const
      script = folder / "num.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 1]
"""

    checkLeak()

  test "String":
    const
      script = folder / "string.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 1]
"""

    checkLeak()

  test "Object":
    const
      script = folder / "object.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 4]
"""

    checkLeak()

suite "Class":
  const folder = "class"

  test "empty":
    const
      script = folder / "empty.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    checkLeak()

  test "Local reference self":
    const
      script = folder / "local_reference_self.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    checkLeak()

  test "Reference self":
    const
      script = folder / "reference_self.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    checkLeak()

  test "Inherit self":
    const
      script = folder / "inherit_self.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'Foo': A class can't inherit from itself.
"""

    checkLeak()

  test "Inherited method":
    const
      script = folder / "inherited_method.lox"
      expectedExitCode = 0
      expectedOutput = """in foo
in bar
in baz
"""

    checkLeak()

  test "Local inherit other":
    const
      script = folder / "local_inherit_other.lox"
      expectedExitCode = 0
      expectedOutput = """B
"""

    checkLeak()

  test "Local inherit self":
    const
      script = folder / "local_inherit_self.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'Foo': A class can't inherit from itself.
"""

    checkLeak()

suite "Closure":
  const folder = "closure"

  test "Assign to closure":
    const
      script = folder / "assign_to_closure.lox"
      expectedExitCode = 0
      expectedOutput = """local
after f
after f
after g
"""

    checkLeak()

  test "Close over function parameter":
    const
      script = folder / "close_over_function_parameter.lox"
      expectedExitCode = 0
      expectedOutput = """param
"""

    checkLeak()

  test "Close over later variable":
    const
      script = folder / "close_over_later_variable.lox"
      expectedExitCode = 0
      expectedOutput = """b
a
"""

    checkLeak()

  test "Closed closure in function":
    const
      script = folder / "closed_closure_in_function.lox"
      expectedExitCode = 0
      expectedOutput = """local
"""

    checkLeak()

  test "Nested closure":
    const
      script = folder / "nested_closure.lox"
      expectedExitCode = 0
      expectedOutput = """a
b
c
"""

    checkLeak()

  test "Open closure in function":
    const
      script = folder / "open_closure_in_function.lox"
      expectedExitCode = 0
      expectedOutput = """local
"""

    checkLeak()

  test "Reference closure multiple times":
    const
      script = folder / "reference_closure_multiple_times.lox"
      expectedExitCode = 0
      expectedOutput = """a
a
"""

    checkLeak()

  test "Reuse closure slot":
    const
      script = folder / "reuse_closure_slot.lox"
      expectedExitCode = 0
      expectedOutput = """a
"""

    checkLeak()

  test "Shadow closure with local":
    const
      script = folder / "shadow_closure_with_local.lox"
      expectedExitCode = 0
      expectedOutput = """closure
shadow
closure
"""

    checkLeak()

  test "Unused closure":
    const
      script = folder / "unused_closure.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

  test "Unused later closure":
    const
      script = folder / "unused_later_closure.lox"
      expectedExitCode = 0
      expectedOutput = """a
"""

    checkLeak()

  test "Assign to shadowed later":
    const
      script = folder / "assign_to_shadowed_later.lox"
      expectedExitCode = 0
      expectedOutput = """inner
assigned
"""

    checkLeak()

  test "Close over method parameter":
    const
      script = folder / "close_over_method_parameter.lox"
      expectedExitCode = 0
      expectedOutput = """param
"""

    checkLeak()

suite "Comments":
  const folder = "comments"

  test "Line at EOF":
    const
      script = folder / "line_at_eof.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

  test "Only line comment and line":
    const
      script = folder / "only_line_comment_and_line.lox"
      expectedExitCode = 0
      expectedOutput = """
"""

    checkLeak()

  test "Only line comment":
    const
      script = folder / "only_line_comment.lox"
      expectedExitCode = 0
      expectedOutput = """
"""

    checkLeak()

  test "Unicode":
    const
      script = folder / "unicode.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

suite "Constructor":
  const folder = "constructor"

  test "Arguments":
    const
      script = folder / "arguments.lox"
      expectedExitCode = 0
      expectedOutput = """init
1
2
"""

    checkLeak()

  test "Call init early return":
    const
      script = folder / "call_init_early_return.lox"
      expectedExitCode = 0
      expectedOutput = """init
init
Foo instance
"""

    checkLeak()

  test "Call init explicitly":
    const
      script = folder / "call_init_explicitly.lox"
      expectedExitCode = 0
      expectedOutput = """Foo.init(one)
Foo.init(two)
Foo instance
init
"""

    checkLeak()

  test "Default arguments":
    const
      script = folder / "default_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 0 arguments but got 3.
[line 3]
"""

    checkLeak()

  test "Default":
    const
      script = folder / "default.lox"
      expectedExitCode = 0
      expectedOutput = """Foo instance
"""

    checkLeak()

  test "Early return":
    const
      script = folder / "early_return.lox"
      expectedExitCode = 0
      expectedOutput = """init
Foo instance
"""

    checkLeak()

  test "Extra arguments":
    const
      script = folder / "extra_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 4.
[line 8]
"""

    checkLeak()

  test "Init not method":
    const
      script = folder / "init_not_method.lox"
      expectedExitCode = 0
      expectedOutput = """not initializer
"""

    checkLeak()

  test "Missing arguments":
    const
      script = folder / "missing_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 1.
[line 5]
"""

    checkLeak()

  test "Return in nested function":
    const
      script = folder / "return_in_nested_function.lox"
      expectedExitCode = 0
      expectedOutput = """bar
Foo instance
"""

    checkLeak()

  test "Return value":
    const
      script = folder / "return_value.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'return': Can't return a value from an initializer.
"""

    checkLeak()

suite "Field":
  const folder = "field"

  test "Call function field":
    const
      script = folder / "call_function_field.lox"
      expectedExitCode = 0
      expectedOutput = """bar
1
2
"""

    checkLeak()

  test "Call nonfunction field":
    const
      script = folder / "call_nonfunction_field.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 6]
"""

    checkLeak()

  test "Get and set method":
    const
      script = folder / "get_and_set_method.lox"
      expectedExitCode = 0
      expectedOutput = """other
1
method
2
"""

    checkLeak()

  test "Get on bool":
    const
      script = folder / "get_on_bool.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 1]
"""

    checkLeak()

  test "Get on class":
    const
      script = folder / "get_on_class.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 2]
"""

    checkLeak()

  test "Get on function":
    const
      script = folder / "get_on_function.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 3]
"""

    checkLeak()

  test "Get on nil":
    const
      script = folder / "get_on_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 1]
"""

    checkLeak()

  test "Get on num":
    const
      script = folder / "get_on_num.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 1]
"""

    checkLeak()

  test "Get on string":
    const
      script = folder / "get_on_string.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 1]
"""

    checkLeak()

  test "Many":
    const
      script = folder / "many.lox"
      expectedExitCode = 0
      expectedOutput = """apple
apricot
avocado
banana
bilberry
blackberry
blackcurrant
blueberry
boysenberry
cantaloupe
cherimoya
cherry
clementine
cloudberry
coconut
cranberry
currant
damson
date
dragonfruit
durian
elderberry
feijoa
fig
gooseberry
grape
grapefruit
guava
honeydew
huckleberry
jabuticaba
jackfruit
jambul
jujube
juniper
kiwifruit
kumquat
lemon
lime
longan
loquat
lychee
mandarine
mango
marionberry
melon
miracle
mulberry
nance
nectarine
olive
orange
papaya
passionfruit
peach
pear
persimmon
physalis
pineapple
plantain
plum
plumcot
pomegranate
pomelo
quince
raisin
rambutan
raspberry
redcurrant
salak
salmonberry
satsuma
strawberry
tamarillo
tamarind
tangerine
tomato
watermelon
yuzu
"""

    checkLeak()

  test "Method binds this":
    const
      script = folder / "method_binds_this.lox"
      expectedExitCode = 0
      expectedOutput = """foo1
1
"""

    checkLeak()

  test "Method":
    const
      script = folder / "method.lox"
      expectedExitCode = 0
      expectedOutput = """got method
arg
"""

    checkLeak()

  test "On instance":
    const
      script = folder / "on_instance.lox"
      expectedExitCode = 0
      expectedOutput = """bar value
baz value
bar value
baz value
"""

    checkLeak()

  test "Set evaluation order":
    const
      script = folder / "set_evaluation_order.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'undefined1'.
[line 1]
"""

    checkLeak()

  test "Set on bool":
    const
      script = folder / "set_on_bool.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 1]
"""

    checkLeak()

  test "Set on class":
    const
      script = folder / "set_on_class.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 2]
"""

    checkLeak()

  test "Set on function":
    const
      script = folder / "set_on_function.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 3]
"""

    checkLeak()

  test "Set on nil":
    const
      script = folder / "set_on_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 1]
"""

    checkLeak()

  test "Set on num":
    const
      script = folder / "set_on_num.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 1]
"""

    checkLeak()

  test "Set on string":
    const
      script = folder / "set_on_string.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 1]
"""

    checkLeak()

  test "Undefined":
    const
      script = folder / "undefined.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined property 'bar'.
[line 4]
"""

    checkLeak()

suite "For":
  const folder = "for"

  test "Scope":
    const
      script = folder / "scope.lox"
      expectedExitCode = 0
      expectedOutput = """0
-1
after
0
"""

    checkLeak()

  test "Statement condition":
    const
      script = folder / "statement_condition.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at '{': Expect expression.
[line 3] Error at ')': Expect ';' after expression.
"""

    checkLeak()

  test "Statement increment":
    const
      script = folder / "statement_increment.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at '{': Expect expression.
"""

    checkLeak()

  test "Statement initializer":
    const
      script = folder / "statement_initializer.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at '{': Expect expression.
[line 3] Error at ')': Expect ';' after expression.
"""

    checkLeak()

  test "Var in body":
    const
      script = folder / "var_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'var': Expect expression.
"""

    checkLeak()

  test "Closure in body":
    const
      script = folder / "closure_in_body.lox"
      expectedExitCode = 0
      expectedOutput = """4
1
4
2
4
3
"""

    checkLeak()

  test "Fun in body":
    const
      script = folder / "fun_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'fun': Expect expression.
"""

    checkLeak()

  test "Return closure":
    const
      script = folder / "return_closure.lox"
      expectedExitCode = 0
      expectedOutput = """i
"""

    checkLeak()

  test "Return inside":
    const
      script = folder / "return_inside.lox"
      expectedExitCode = 0
      expectedOutput = """i
"""

    checkLeak()

  test "Syntax":
    const
      script = folder / "syntax.lox"
      expectedExitCode = 0
      expectedOutput = """1
2
3
0
1
2
done
0
1
0
1
2
0
1
"""

    checkLeak()

  test "Class in body":
    const
      script = folder / "class_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'class': Expect expression.
"""

    checkLeak()

suite "Function":
  const folder = "function"

  test "Body must be block":
    const
      script = folder / "body_must_be_block.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at '123': Expect '{' before function body.
"""

    checkLeak()

  test "Empty body":
    const
      script = folder / "empty_body.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    checkLeak()

  test "Extra arguments":
    const
      script = folder / "extra_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 4.
[line 6]
"""

    checkLeak()

  test "Local recursion":
    const
      script = folder / "local_recursion.lox"
      expectedExitCode = 0
      expectedOutput = """21
"""

    checkLeak()

  test "Missing arguments":
    const
      script = folder / "missing_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 1.
[line 3]
"""

    checkLeak()

  test "Missing comma in parameters":
    const
      script = folder / "missing_comma_in_parameters.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'c': Expect ')' after parameters.
"""

    checkLeak()

  test "Mutual recursion":
    const
      script = folder / "mutual_recursion.lox"
      expectedExitCode = 0
      expectedOutput = """true
true
"""

    checkLeak()

  test "Nested call with arguments":
    const
      script = folder / "nested_call_with_arguments.lox"
      expectedExitCode = 0
      expectedOutput = """hello world
"""

    checkLeak()

  test "Parameters":
    const
      script = folder / "parameters.lox"
      expectedExitCode = 0
      expectedOutput = """0
1
3
6
10
15
21
28
36
"""

    checkLeak()

  test "Print":
    const
      script = folder / "print.lox"
      expectedExitCode = 0
      expectedOutput = """<fn foo>
<native fn>
"""

    checkLeak()

  test "Recursion":
    const
      script = folder / "recursion.lox"
      expectedExitCode = 0
      expectedOutput = """21
"""

    checkLeak()

  test "Too many arguments":
    const
      script = folder / "too_many_arguments.lox"
      expectedExitCode = 65
      expectedOutput = """[line 260] Error at 'a': Can't have more than 255 arguments.
"""

    checkLeak()

  test "Too many parameters":
    const
      script = folder / "too_many_parameters.lox"
      expectedExitCode = 65
      expectedOutput = """[line 257] Error at 'a': Can't have more than 255 parameters.
"""

    checkLeak()

  test "Local mutual recursion":
    const
      script = folder / "local_mutual_recursion.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'isOdd'.
[line 4]
"""

    checkLeak()

suite "If":
  const folder = "if"

  test "Dangling else":
    const
      script = folder / "dangling_else.lox"
      expectedExitCode = 0
      expectedOutput = """good
"""

    checkLeak()

  test "Else":
    const
      script = folder / "else.lox"
      expectedExitCode = 0
      expectedOutput = """good
good
block
"""

    checkLeak()

  test "If":
    const
      script = folder / "if.lox"
      expectedExitCode = 0
      expectedOutput = """good
block
true
"""

    checkLeak()

  test "Truth":
    const
      script = folder / "truth.lox"
      expectedExitCode = 0
      expectedOutput = """false
nil
true
0
empty
"""

    checkLeak()

  test "Var in else":
    const
      script = folder / "var_in_else.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'var': Expect expression.
"""

    checkLeak()

  test "Var in then":
    const
      script = folder / "var_in_then.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'var': Expect expression.
"""

    checkLeak()

  test "Fun in else":
    const
      script = folder / "fun_in_else.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'fun': Expect expression.
"""

    checkLeak()

  test "Fun in then":
    const
      script = folder / "fun_in_then.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'fun': Expect expression.
"""

    checkLeak()

  test "Class in else":
    const
      script = folder / "class_in_else.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'class': Expect expression.
"""

    checkLeak()

  test "Class in then":
    const
      script = folder / "class_in_then.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'class': Expect expression.
"""

    checkLeak()

suite "Inheritance":
  const folder = "inheritance"

  test "Constructor":
    const
      script = folder / "constructor.lox"
      expectedExitCode = 0
      expectedOutput = """value
"""

    checkLeak()

  test "Inherit from function":
    const
      script = folder / "inherit_from_function.lox"
      expectedExitCode = 70
      expectedOutput = """Superclass must be a class.
[line 3]
"""

    checkLeak()

  test "Inherit from nil":
    const
      script = folder / "inherit_from_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Superclass must be a class.
[line 2]
"""

    checkLeak()

  test "Inherit from number":
    const
      script = folder / "inherit_from_number.lox"
      expectedExitCode = 70
      expectedOutput = """Superclass must be a class.
[line 2]
"""

    checkLeak()

  test "Inherit methods":
    const
      script = folder / "inherit_methods.lox"
      expectedExitCode = 0
      expectedOutput = """foo
bar
bar
"""

    checkLeak()

  test "Parenthesized superclass":
    const
      script = folder / "parenthesized_superclass.lox"
      expectedExitCode = 65
      expectedOutput = """[line 4] Error at '(': Expect superclass name.
"""

    checkLeak()

  test "Set fields from base class":
    const
      script = folder / "set_fields_from_base_class.lox"
      expectedExitCode = 0
      expectedOutput = """foo 1
foo 2
bar 1
bar 2
bar 1
bar 2
"""

    checkLeak()

suite "Logical Operator":
  const folder = "logical_operator"

  test "And truth":
    const
      script = folder / "and_truth.lox"
      expectedExitCode = 0
      expectedOutput = """false
nil
ok
ok
ok
"""

    checkLeak()

  test "And":
    const
      script = folder / "and.lox"
      expectedExitCode = 0
      expectedOutput = """false
1
false
true
3
true
false
"""

    checkLeak()

  test "Or truth":
    const
      script = folder / "or_truth.lox"
      expectedExitCode = 0
      expectedOutput = """ok
ok
true
0
s
"""

    checkLeak()

  test "Or":
    const
      script = folder / "or.lox"
      expectedExitCode = 0
      expectedOutput = """1
1
true
false
false
false
true
"""

    checkLeak()

suite "Method":
  const folder = "method"

  test "Arity":
    const
      script = folder / "arity.lox"
      expectedExitCode = 0
      expectedOutput = """no args
1
3
6
10
15
21
28
36
"""

    checkLeak()

  test "Arity":
    const
      script = folder / "empty_block.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    checkLeak()

  test "Extra arguments":
    const
      script = folder / "extra_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 4.
[line 8]
"""

    checkLeak()

  test "Missing arguments":
    const
      script = folder / "missing_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 1.
[line 5]
"""

    checkLeak()

  test "Not found":
    const
      script = folder / "not_found.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined property 'unknown'.
[line 3]
"""

    checkLeak()

  test "Print bound method":
    const
      script = folder / "print_bound_method.lox"
      expectedExitCode = 0
      expectedOutput = """<fn method>
"""

    checkLeak()

  test "Refer to name":
    const
      script = folder / "refer_to_name.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'method'.
[line 3]
"""

    checkLeak()

  test "Too many arguments":
    const
      script = folder / "too_many_arguments.lox"
      expectedExitCode = 65
      expectedOutput = """[line 259] Error at 'a': Can't have more than 255 arguments.
"""

    checkLeak()

  test "Too many parameters":
    const
      script = folder / "too_many_parameters.lox"
      expectedExitCode = 65
      expectedOutput = """[line 258] Error at 'a': Can't have more than 255 parameters.
"""

    checkLeak()

suite "Nil":
  const folder = "nil"

  test "Literal":
    const
      script = folder / "literal.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    checkLeak()

suite "Number":
  const folder = "number"

  test "Leading dot":
    const
      script = folder / "leading_dot.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at '.': Expect expression.
"""

    checkLeak()

  test "Literals":
    const
      script = folder / "literals.lox"
      expectedExitCode = 0
      expectedOutput = """123
987654
0
-0
123.456
-0.001
"""

    checkLeak()

  test "NaN equality":
    const
      script = folder / "nan_equality.lox"
      expectedExitCode = 0
      expectedOutput = """false
true
true
false
"""

    checkLeak()

  test "Decimal point at eof":
    const
      script = folder / "decimal_point_at_eof.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at end: Expect property name after '.'.
"""

    checkLeak()

  test "Trailing dot":
    const
      script = folder / "trailing_dot.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at ';': Expect property name after '.'.
"""

    checkLeak()

suite "Operator":
  const folder = "operator"

  test "Add bool nil":
    const
      script = folder / "add_bool_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    checkLeak()

  test "Add bool num":
    const
      script = folder / "add_bool_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    checkLeak()

  test "Add bool string":
    const
      script = folder / "add_bool_string.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    checkLeak()

  test "Add nil nil":
    const
      script = folder / "add_nil_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    checkLeak()

  test "Add num nil":
    const
      script = folder / "add_num_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    checkLeak()

  test "Add string nil":
    const
      script = folder / "add_string_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be two numbers or two strings.
[line 1]
"""

    checkLeak()

  test "Add":
    const
      script = folder / "add.lox"
      expectedExitCode = 0
      expectedOutput = """579
string
"""

    checkLeak()

  test "Comparison":
    const
      script = folder / "comparison.lox"
      expectedExitCode = 0
      expectedOutput = """true
false
false
true
true
false
false
false
true
false
true
true
false
false
false
false
true
true
true
true
"""

    checkLeak()

  test "Divide nonnum num":
    const
      script = folder / "divide_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Divide num nonnum":
    const
      script = folder / "divide_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Divide":
    const
      script = folder / "divide.lox"
      expectedExitCode = 0
      expectedOutput = """4
1
"""

    checkLeak()

  test "Equals":
    const
      script = folder / "equals.lox"
      expectedExitCode = 0
      expectedOutput = """true
true
false
true
false
true
false
false
false
false
"""

    checkLeak()

  test "Greater nonnum num":
    const
      script = folder / "greater_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Greater num nonnum":
    const
      script = folder / "greater_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Greater or equal nonnum num":
    const
      script = folder / "greater_or_equal_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Greater or equal num nonnum":
    const
      script = folder / "greater_or_equal_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Less nonnum num":
    const
      script = folder / "less_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Less num nonnum":
    const
      script = folder / "less_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Less or equal nonnum num":
    const
      script = folder / "less_or_equal_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Less or equal num nonnum":
    const
      script = folder / "less_or_equal_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Multiply nonnum num":
    const
      script = folder / "multiply_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Multiply num nonnum":
    const
      script = folder / "multiply_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Multiply":
    const
      script = folder / "multiply.lox"
      expectedExitCode = 0
      expectedOutput = """15
3.702
"""

    checkLeak()

  test "Negate nonnum":
    const
      script = folder / "negate_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operand must be a number.
[line 1]
"""

    checkLeak()

  test "Negate":
    const
      script = folder / "negate.lox"
      expectedExitCode = 0
      expectedOutput = """-3
3
-3
"""

    checkLeak()

  test "Not equals":
    const
      script = folder / "not_equals.lox"
      expectedExitCode = 0
      expectedOutput = """false
false
true
false
true
false
true
true
true
true
"""

    checkLeak()

  test "Subtract nonnum num":
    const
      script = folder / "subtract_nonnum_num.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Subtract num nonnum":
    const
      script = folder / "subtract_num_nonnum.lox"
      expectedExitCode = 70
      expectedOutput = """Operands must be numbers.
[line 1]
"""

    checkLeak()

  test "Subtract":
    const
      script = folder / "subtract.lox"
      expectedExitCode = 0
      expectedOutput = """1
0
"""

    checkLeak()

  test "Not":
    const
      script = folder / "not.lox"
      expectedExitCode = 0
      expectedOutput = """false
true
true
false
false
true
false
false
"""

    checkLeak()

  test "Equals class":
    const
      script = folder / "equals_class.lox"
      expectedExitCode = 0
      expectedOutput = """true
false
false
true
false
false
false
false
"""

    checkLeak()

  test "Equals method":
    const
      script = folder / "equals_method.lox"
      expectedExitCode = 0
      expectedOutput = """true
false
"""

    checkLeak()

  test "Not class":
    const
      script = folder / "not_class.lox"
      expectedExitCode = 0
      expectedOutput = """false
false
"""

    checkLeak()

suite "Others":
  test "Empty file":
    const
      script = "empty_file.lox"
      expectedExitCode = 0
      expectedOutput = """
"""

    checkLeak()

  test "Precedence":
    const
      script = "precedence.lox"
      expectedExitCode = 0
      expectedOutput = """14
8
4
0
true
true
true
true
0
0
0
0
4
"""

    checkLeak()

  test "Unexpected character":
    const
      script = "unexpected_character.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error: Unexpected character.
[line 3] Error at 'b': Expect ')' after arguments.
"""

    checkLeak()

suite "Print":
  const folder = "print"

  test "Missing argument":
    const
      script = folder / "missing_argument.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at ';': Expect expression.
"""

    checkLeak()

suite "Regression":
  const folder = "regression"

  test "40":
    const
      script = folder / "40.lox"
      expectedExitCode = 0
      expectedOutput = """false
"""

    checkLeak()

  test "394":
    const
      script = folder / "394.lox"
      expectedExitCode = 0
      expectedOutput = """B
"""

    checkLeak()

suite "Return":
  const folder = "return"

  test "After else":
    const
      script = folder / "after_else.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

  test "After if":
    const
      script = folder / "after_if.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

  test "After while":
    const
      script = folder / "after_while.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

  test "In function":
    const
      script = folder / "in_function.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

  test "Return nil if no value":
    const
      script = folder / "return_nil_if_no_value.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    checkLeak()

  test "At top level":
    const
      script = folder / "at_top_level.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'return': Can't return from top-level code.
"""

    checkLeak()

  test "In method":
    const
      script = folder / "in_method.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

suite "String":
  const folder = "string"

  test "Error after multiline":
    const
      script = folder / "error_after_multiline.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'err'.
[line 7]
"""

    checkLeak()

  test "Literals":
    const
      script = folder / "literals.lox"
      expectedExitCode = 0
      expectedOutput = """()
a string
A~¶Þॐஃ
"""

    checkLeak()

  test "Multiline":
    const
      script = folder / "multiline.lox"
      expectedExitCode = 0
      expectedOutput = """1
2
3
"""

    checkLeak()

  test "Unterminated":
    const
      script = folder / "unterminated.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error: Unterminated string.
"""

    checkLeak()

suite "Super":
  const folder = "super"

  test "Bound method":
    const
      script = folder / "bound_method.lox"
      expectedExitCode = 0
      expectedOutput = """A.method(arg)
"""

    checkLeak()

  test "Call other method":
    const
      script = folder / "call_other_method.lox"
      expectedExitCode = 0
      expectedOutput = """Derived.bar()
Base.foo()
"""

    checkLeak()

  test "Call same method":
    const
      script = folder / "call_same_method.lox"
      expectedExitCode = 0
      expectedOutput = """Derived.foo()
Base.foo()
"""

    checkLeak()

  test "Closure":
    const
      script = folder / "closure.lox"
      expectedExitCode = 0
      expectedOutput = """Base
"""

    checkLeak()

  test "Constructor":
    const
      script = folder / "constructor.lox"
      expectedExitCode = 0
      expectedOutput = """Derived.init()
Base.init(a, b)
"""

    checkLeak()

  test "Extra arguments":
    const
      script = folder / "extra_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Derived.foo()
Expected 2 arguments but got 4.
[line 10]
"""

    checkLeak()

  test "Indirectly inherited":
    const
      script = folder / "indirectly_inherited.lox"
      expectedExitCode = 0
      expectedOutput = """C.foo()
A.foo()
"""

    checkLeak()

  test "Missing arguments":
    const
      script = folder / "missing_arguments.lox"
      expectedExitCode = 70
      expectedOutput = """Expected 2 arguments but got 1.
[line 9]
"""

    checkLeak()

  test "No superclass bind":
    const
      script = folder / "no_superclass_bind.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'super': Can't use 'super' in a class with no superclass.
"""

    checkLeak()

  test "No superclass call":
    const
      script = folder / "no_superclass_call.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'super': Can't use 'super' in a class with no superclass.
"""

    checkLeak()

  test "No superclass method":
    const
      script = folder / "no_superclass_method.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined property 'doesNotExist'.
[line 5]
"""

    checkLeak()

  test "Parenthesized":
    const
      script = folder / "parenthesized.lox"
      expectedExitCode = 65
      expectedOutput = """[line 8] Error at ')': Expect '.' after 'super'.
"""

    checkLeak()

  test "Reassign superclass":
    const
      script = folder / "reassign_superclass.lox"
      expectedExitCode = 0
      expectedOutput = """Base.method()
Base.method()
"""

    checkLeak()

  test "Super at top level":
    const
      script = folder / "super_at_top_level.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'super': Can't use 'super' outside of a class.
[line 2] Error at 'super': Can't use 'super' outside of a class.
"""

    checkLeak()

  test "Super in closure in inherited method":
    const
      script = folder / "super_in_closure_in_inherited_method.lox"
      expectedExitCode = 0
      expectedOutput = """A
"""

    checkLeak()

  test "Super in inherited method":
    const
      script = folder / "super_in_inherited_method.lox"
      expectedExitCode = 0
      expectedOutput = """A
"""

    checkLeak()

  test "Super in top level function":
    const
      script = folder / "super_in_top_level_function.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'super': Can't use 'super' outside of a class.
"""

    checkLeak()

  test "Super without dot":
    const
      script = folder / "super_without_dot.lox"
      expectedExitCode = 65
      expectedOutput = """[line 6] Error at ';': Expect '.' after 'super'.
"""

    checkLeak()

  test "Super without name":
    const
      script = folder / "super_without_name.lox"
      expectedExitCode = 65
      expectedOutput = """[line 5] Error at ';': Expect superclass method name.
"""

    checkLeak()

  test "This in superclass method":
    const
      script = folder / "this_in_superclass_method.lox"
      expectedExitCode = 0
      expectedOutput = """a
b
"""

    checkLeak()

suite "This":
  const folder = "this"

  test "Closure":
    const
      script = folder / "closure.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    checkLeak()

  test "Nested class":
    const
      script = folder / "nested_class.lox"
      expectedExitCode = 0
      expectedOutput = """Outer instance
Outer instance
Inner instance
"""

    checkLeak()

  test "Nested closure":
    const
      script = folder / "nested_closure.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    checkLeak()

  test "This at top level":
    const
      script = folder / "this_at_top_level.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'this': Can't use 'this' outside of a class.
"""

    checkLeak()

  test "This in method":
    const
      script = folder / "this_in_method.lox"
      expectedExitCode = 0
      expectedOutput = """baz
"""

    checkLeak()

  test "This in top level function":
    const
      script = folder / "this_in_top_level_function.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'this': Can't use 'this' outside of a class.
"""

    checkLeak()

suite "Variable":
  const folder = "variable"

  test "In middle of block":
    const
      script = folder / "in_middle_of_block.lox"
      expectedExitCode = 0
      expectedOutput = """a
a b
a c
a b d
"""

    checkLeak()

  test "In nested block":
    const
      script = folder / "in_nested_block.lox"
      expectedExitCode = 0
      expectedOutput = """outer
"""

    checkLeak()

  test "Redeclare global":
    const
      script = folder / "redeclare_global.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    checkLeak()

  test "Redefine global":
    const
      script = folder / "redefine_global.lox"
      expectedExitCode = 0
      expectedOutput = """2
"""

    checkLeak()

  test "Scope reuse in different blocks":
    const
      script = folder / "scope_reuse_in_different_blocks.lox"
      expectedExitCode = 0
      expectedOutput = """first
second
"""

    checkLeak()

  test "Shadow and local":
    const
      script = folder / "shadow_and_local.lox"
      expectedExitCode = 0
      expectedOutput = """outer
inner
"""

    checkLeak()

  test "Shadow global":
    const
      script = folder / "shadow_global.lox"
      expectedExitCode = 0
      expectedOutput = """shadow
global
"""

    checkLeak()

  test "Shadow local":
    const
      script = folder / "shadow_local.lox"
      expectedExitCode = 0
      expectedOutput = """shadow
local
"""

    checkLeak()

  test "Undefined global":
    const
      script = folder / "undefined_global.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'notDefined'.
[line 1]
"""

    checkLeak()

  test "Undefined local":
    const
      script = folder / "undefined_local.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'notDefined'.
[line 2]
"""

    checkLeak()

  test "Uninitialized":
    const
      script = folder / "uninitialized.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    checkLeak()

  test "Use false as var":
    const
      script = folder / "use_false_as_var.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'false': Expect variable name.
"""

    checkLeak()

  test "Use global in initializer":
    const
      script = folder / "use_global_in_initializer.lox"
      expectedExitCode = 0
      expectedOutput = """value
"""

    checkLeak()

  test "Use nil as var":
    const
      script = folder / "use_nil_as_var.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'nil': Expect variable name.
"""

    checkLeak()

  test "Use this as var":
    const
      script = folder / "use_this_as_var.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'this': Expect variable name.
"""

    checkLeak()

  test "Unreached undefined":
    const
      script = folder / "unreached_undefined.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    checkLeak()

  test "Collide with parameter":
    const
      script = folder / "collide_with_parameter.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'a': Already a variable with this name in this scope.
"""

    checkLeak()

  test "Duplicate local":
    const
      script = folder / "duplicate_local.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'a': Already a variable with this name in this scope.
"""

    checkLeak()

  test "Duplicate parameter":
    const
      script = folder / "duplicate_parameter.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'arg': Already a variable with this name in this scope.
"""

    checkLeak()

  test "Early bound":
    const
      script = folder / "early_bound.lox"
      expectedExitCode = 0
      expectedOutput = """outer
outer
"""

    checkLeak()

  test "User local in initializer":
    const
      script = folder / "use_local_in_initializer.lox"
      expectedExitCode = 65
      expectedOutput = """[line 3] Error at 'a': Can't read local variable in its own initializer.
"""

    checkLeak()

  test "Local from method":
    const
      script = folder / "local_from_method.lox"
      expectedExitCode = 0
      expectedOutput = """variable
"""

    checkLeak()

suite "While":
  const folder = "while"

  test "Syntax":
    const
      script = folder / "syntax.lox"
      expectedExitCode = 0
      expectedOutput = """1
2
3
0
1
2
"""

    checkLeak()

  test "Var in body":
    const
      script = folder / "var_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'var': Expect expression.
"""

    checkLeak()

  test "Closure in body":
    const
      script = folder / "closure_in_body.lox"
      expectedExitCode = 0
      expectedOutput = """1
2
3
"""

    checkLeak()

  test "Fun in body":
    const
      script = folder / "fun_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'fun': Expect expression.
"""

    checkLeak()

  test "Return closure":
    const
      script = folder / "return_closure.lox"
      expectedExitCode = 0
      expectedOutput = """i
"""

    checkLeak()

  test "Return inside":
    const
      script = folder / "return_inside.lox"
      expectedExitCode = 0
      expectedOutput = """i
"""

    checkLeak()

  test "Class in body":
    const
      script = folder / "class_in_body.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'class': Expect expression.
"""

    checkLeak()
