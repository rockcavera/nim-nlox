{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "number"

suite "Number":
  test "Leading dot":
    const
      script = folder / "leading_dot.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at '.': Expect expression.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Literals":
    const
      script = folder / "literals.lox"
      expectedExitCode = 0
      expectedOutput = """123
987654
0
-0
123.456
-0.001
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "NaN equality":
    const
      script = folder / "nan_equality.lox"
      expectedExitCode = 0
      expectedOutput = """false
true
true
false
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Decimal point at eof":
    const
      script = folder / "decimal_point_at_eof.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at end: Expect property name after '.'.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Trailing dot":
    const
      script = folder / "trailing_dot.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error at ';': Expect property name after '.'.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
