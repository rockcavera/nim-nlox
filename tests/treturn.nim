{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "return"

suite "Return":
  test "After else":
    const
      script = folder / "after_else.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "After if":
    const
      script = folder / "after_if.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "After while":
    const
      script = folder / "after_while.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "In function":
    const
      script = folder / "in_function.lox"
      expectedExitCode = 0
      expectedOutput = """ok
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Return nil if no value":
    const
      script = folder / "return_nil_if_no_value.lox"
      expectedExitCode = 0
      expectedOutput = """nil
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
