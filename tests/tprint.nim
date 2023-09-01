{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "print"

suite "Print":
  test "Missing argument":
    const
      script = folder / "missing_argument.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at ';': Expect expression.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
