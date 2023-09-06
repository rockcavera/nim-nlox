{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "call"

suite "Call":
  test "bool":
    const
      script = folder / "bool.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "nil":
    const
      script = folder / "nil.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "num":
    const
      script = folder / "num.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "string":
    const
      script = folder / "string.lox"
      expectedExitCode = 70
      expectedOutput = """Can only call functions and classes.
[line 1]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
