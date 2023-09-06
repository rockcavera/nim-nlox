{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "regression"

suite "Regression":
  test "40":
    const
      script = folder / "40.lox"
      expectedExitCode = 0
      expectedOutput = """false
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
