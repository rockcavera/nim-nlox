{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "inheritance"

suite "Inheritance":
  test "Constructor":
    const
      script = folder / "constructor.lox"
      expectedExitCode = 0
      expectedOutput = """value
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Inherit from function":
    const
      script = folder / "inherit_from_function.lox"
      expectedExitCode = 70
      expectedOutput = """Superclass must be a class.
[line 3]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Inherit from nil":
    const
      script = folder / "inherit_from_nil.lox"
      expectedExitCode = 70
      expectedOutput = """Superclass must be a class.
[line 2]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Inherit from number":
    const
      script = folder / "inherit_from_number.lox"
      expectedExitCode = 70
      expectedOutput = """Superclass must be a class.
[line 2]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Inherit methods":
    const
      script = folder / "inherit_methods.lox"
      expectedExitCode = 0
      expectedOutput = """foo
bar
bar
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Parenthesized superclass":
    const
      script = folder / "parenthesized_superclass.lox"
      expectedExitCode = 65
      expectedOutput = """[line 4] Error at '(': Expect superclass name.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

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

    check (expectedOutput, expectedExitCode) == nloxTest(script)
