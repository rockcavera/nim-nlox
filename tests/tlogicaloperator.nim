{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "logical_operator"

suite "Logical Operator":
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

    check (expectedOutput, expectedExitCode) == nloxTest(script)

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

    check (expectedOutput, expectedExitCode) == nloxTest(script)

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

    check (expectedOutput, expectedExitCode) == nloxTest(script)

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

    check (expectedOutput, expectedExitCode) == nloxTest(script)
