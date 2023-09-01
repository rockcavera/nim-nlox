{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "nil"

suite "Nil":
  test "Literal":
    const
      script = folder / "literal.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
