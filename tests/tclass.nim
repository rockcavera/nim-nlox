{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "class"

suite "Class":
  test "empty":
    const
      script = folder / "empty.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Local reference self":
    const
      script = folder / "local_reference_self.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Reference self":
    const
      script = folder / "reference_self.lox"
      expectedExitCode = 0
      expectedOutput = """Foo
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Inherit self":
    const
      script = folder / "inherit_self.lox"
      expectedExitCode = 65
      expectedOutput = """[line 1] Error at 'Foo': A class can't inherit from itself.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Inherited method":
    const
      script = folder / "inherited_method.lox"
      expectedExitCode = 0
      expectedOutput = """in foo
in bar
in baz
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Local inherit other":
    const
      script = folder / "local_inherit_other.lox"
      expectedExitCode = 0
      expectedOutput = """B
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Local inherit self":
    const
      script = folder / "local_inherit_self.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at 'Foo': A class can't inherit from itself.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
