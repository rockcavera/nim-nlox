{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "field"

suite "Field":
  test "Call function field":
    const
      script = folder / "call_function_field.lox"
      expectedExitCode = 0
      expectedOutput = """bar
1
2
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Call nonfunction field":
    const
      script = folder / "call_nonfunction_field.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 6]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Get and set method":
    const
      script = folder / "get_and_set_method.lox"
      expectedExitCode = 0
      expectedOutput = """other
1
method
2
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Get on bool":
    const
      script = folder / "get_on_bool.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Get on class":
    const
      script = folder / "get_on_class.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 2]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Get on function":
    const
      script = folder / "get_on_function.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 3]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Get on nil":
    const
      script = folder / "get_on_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Get on num":
    const
      script = folder / "get_on_num.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Get on string":
    const
      script = folder / "get_on_string.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have properties.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

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

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Method binds this":
    const
      script = folder / "method_binds_this.lox"
      expectedExitCode = 0
      expectedOutput = """foo1
1
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Method":
    const
      script = folder / "method.lox"
      expectedExitCode = 0
      expectedOutput = """got method
arg
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "On instance":
    const
      script = folder / "on_instance.lox"
      expectedExitCode = 0
      expectedOutput = """bar value
baz value
bar value
baz value
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Set evaluation order":
    const
      script = folder / "set_evaluation_order.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'undefined1'.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Set on bool":
    const
      script = folder / "set_on_bool.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Set on class":
    const
      script = folder / "set_on_class.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 2]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Set on function":
    const
      script = folder / "set_on_function.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 3]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Set on nil":
    const
      script = folder / "set_on_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Set on num":
    const
      script = folder / "set_on_num.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Set on string":
    const
      script = folder / "set_on_string.lox"
      expectedExitCode = 70
      expectedOutput = """Only instances have fields.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Undefined":
    const
      script = folder / "undefined.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined property 'bar'.
[line 4]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
