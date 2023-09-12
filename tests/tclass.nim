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
