{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "bool"

suite "Bool":
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

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Not":
    const
      script = folder / "not.lox"
      expectedExitCode = 0
      expectedOutput = """false
true
true
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
