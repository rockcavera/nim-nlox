{.used.}
import std/private/[ospaths2], std/unittest

import ./tconfig

const folder = "string"

suite "String":
  test "Error after multiline":
    const
      script = folder / "error_after_multiline.lox"
      expectedExitCode = 70
      expectedOutput = """Undefined variable 'err'.
[line 7]
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Literals":
    const
      script = folder / "literals.lox"
      expectedExitCode = 0
      expectedOutput = """()
a string
A~¶Þॐஃ
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Multiline":
    const
      script = folder / "multiline.lox"
      expectedExitCode = 0
      expectedOutput = """1
2
3
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)

  test "Unterminated":
    const
      script = folder / "unterminated.lox"
      expectedExitCode = 65
      expectedOutput = """[line 2] Error: Unterminated string.
"""

    check (expectedOutput, expectedExitCode) == nloxTest(script)
